//
//  ViewController.swift
//  fml
//
//  Created by Hanno Bruns on 17.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit
import Parse
import SwiftyUserDefaults

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadNewPostsButton: UIButton!
    var dataSouce = [PFObject]()
    var votes = [String : String]()
    let dateformatter = NSDateFormatter()
    let refreshControl = UIRefreshControl()
    var timer: NSTimer?
    var viewjustloaded = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "start_screen_title".localizedString
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        dateformatter.dateStyle = .LongStyle
        dateformatter.locale = NSLocale(localeIdentifier: NSLocale.preferredLanguages()[0])
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "pullToRefreshUpdateRemote", forControlEvents: .ValueChanged)
        updateVotesArray()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        scheduleTimer()
        updateLoadNewPostsButtonState()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshControl.superview?.sendSubviewToBack(refreshControl)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if Defaults[.lastRemoteUpdated] == nil {
            loadPosts(false, keepScrollPosition: false, success: nil)
        } else {
            loadPosts(true, keepScrollPosition: true, success: { () -> () in
                if self.viewjustloaded {
                    self.tableView.contentOffset.y = CGFloat(Defaults[.lastTableViewContentOffsetY])
                    self.viewjustloaded = false
                }
            })
        }
        scheduleTimer()
    }
    
    func scheduleTimer() {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "updateInBackground", userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func updateVotesArray() {
        let query = PFQuery(className: "Vote")
        query.whereKeyExists("post")
        query.whereKeyDoesNotExist("comment")
        query.fromLocalDatastore()
        query.limit = 1000 // TODO add support for more than 1000 votes
        query.findObjectsInBackgroundWithBlock { (votes: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("searching local vote failed: \(error)")
            } else if let votes = votes {
                self.votes.removeAll()
                for vote in votes {
                    let votePost = vote["post"] as! PFObject
                    self.votes[votePost.objectId!] = vote["kind"] as? String
                }
            }
        }
    }
    
    func updateLoadNewPostsButtonState() {
        if Defaults[.countNewPosts] > 0 {
            loadNewPostsButton.hidden = false
            var title = "load_new_posts_button_title".localizedString
            title = title.stringByReplacingString("#count#", with: "\(Defaults[.countNewPosts])")
            loadNewPostsButton.setTitle(title, forState: .Normal)
        } else {
            loadNewPostsButton.hidden = true
        }
    }
    
    func updateInBackground() {
        self.updateRemote({ () -> () in
            self.loadPosts(true, keepScrollPosition: true, success: nil)
        })
    }
    
    func pullToRefreshUpdateRemote() {
        updateRemote { () -> () in
            self.loadPosts(true, keepScrollPosition: false, success: nil)
        }
    }
    
    func saveLastTableViewContentOffsetY() {
        Defaults[.lastTableViewContentOffsetY] = Double(tableView.contentOffset.y)
    }
    
    func didEnterBackground(notification: NSNotification) {
        saveLastTableViewContentOffsetY()
    }
    
    func loadPosts(locally: Bool, keepScrollPosition: Bool, success: (() -> ())?) {
        let query = getQuery()
        query.addDescendingOrder("createdAt")
        if locally {
            query.fromLocalDatastore()
        }
        if keepScrollPosition {
            var lastLocalUpdated = NSDate(timeIntervalSinceNow: 0)
            if let savedLastLocalUpdated = Defaults[.lastLocalUpdated] {
                lastLocalUpdated = savedLastLocalUpdated
            } else {
                Defaults[.lastLocalUpdated] = lastLocalUpdated
            }
            query.whereKey("createdAt", lessThanOrEqualTo: lastLocalUpdated)
        } else {
            Defaults[.countNewPosts] = 0
            Defaults[.lastLocalUpdated] = NSDate(timeIntervalSinceNow: 0)
        }
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                UIAlertController.showAlertWithError(error)
            } else if let objects = objects {
                PFObject.pinAllInBackground(objects)
                self.dataSouce = objects
                self.reloadData()
//                }
                if !NSProcessInfo.iOS9OrGreater() { // ios 8 bug fix
                    self.reloadData()
                }
                if !locally {
                    Defaults[.lastRemoteUpdated] = NSDate(timeIntervalSinceNow: 0)
                }
                if let success = success {
                    success()
                }
            }
        }
    }
    
    func reloadData() {
        if NSProcessInfo.iOS9OrGreater() { // another iOS8 bug
            tableView.reloadData()
        } else {
            let contentOffset = tableView.contentOffset
            tableView.reloadData()
            tableView.layoutIfNeeded()
            tableView.contentOffset = contentOffset
        }
    }
    
    func showNewPostsIndicator(count: Int) {
        updateLoadNewPostsButtonState()
    }
    
    func getQuery() -> PFQuery {
        let query = PFQuery(className: Constants.parsePostClassName)
        query.whereKey("lang", equalTo: NSBundle.mainBundle().getPrefrerredLang())
        query.whereKey("hidden", equalTo: NSNumber(bool: false))
        return query
    }
    
    func updateRemote(completion: (() -> ())?) {
        if let lastUpdated = Defaults[.lastRemoteUpdated] {
            let query = getQuery()
            query.whereKey("updatedAt", greaterThan: lastUpdated)
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                self.refreshControl.endRefreshing()
                if let error = error {
                    if self.dataSouce.count == 0 {
                        UIAlertController.showAlertWithError(error)
                    } else {
                        print("silent error: update remote failed with error \(error)\nShowing cached content")
                    }
                } else if let objects = objects {
                    let lastUpdated = Defaults[.lastRemoteUpdated]
                    var newPosts = [PFObject]()
                    for newPost in objects {
                        if newPost.createdAt > lastUpdated {
                            newPosts.append(newPost)
                        }
                    }
                    Defaults[.countNewPosts] += newPosts.count
                    self.showNewPostsIndicator(Defaults[.countNewPosts])
                    Defaults[.lastRemoteUpdated] = NSDate(timeIntervalSinceNow: 0)
                    PFObject.pinAllInBackground(objects, block: { (success: Bool, error: NSError?) -> Void in
                        if let error = error {
                            UIAlertController.showAlertWithError(error)
                        } else {
                            if let completion = completion {
                                completion()
                            }
                        }
                    })
                    print("delta update \(objects)")
                }
            }
        } else {
            refreshControl.endRefreshing()
            print("cannot update because there is no base data")
        }
    }
    
    func saveVote(kind: String, sender: PostCell) {
        if let indexPath = tableView.indexPathForCell(sender) {
            let object = dataSouce[indexPath.row]
            if let postObjectId = object.objectId {
                votes[postObjectId] = kind
            }
            if kind == Constants.upvote {
                object.incrementKey(Constants.countUpvotes)
            } else {
                object.incrementKey(Constants.countDownvotes)
            }
            object.saveEventually()
            let voteObject = PFObject(className: "Vote")
            voteObject["owner"] = PFUser.currentUser()
            voteObject["post"] = object
            voteObject["kind"] = kind
            voteObject.pinInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    self.reloadData()
                }
            })
            voteObject.saveEventually()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func loadNewPostsTouched(sender: AnyObject) {
        loadPosts(true, keepScrollPosition: false) { () -> () in
            self.tableView.setContentOffset(CGPointZero, animated: true)
        }
        Defaults[.countNewPosts] = 0
        updateLoadNewPostsButtonState()
    }

    // MARK: - TableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        let object = dataSouce[indexPath.row]
        cell.resetState()
        cell.messageLabel.text = object["message"] as? String
        var author = object["author"] as? String
        if author == nil {
            author = "anonymous".localizedString
        }
        if let female = object["female"] as? NSNumber {
            if female.boolValue {
                cell.genderLabel.text = ""
            } else {
                cell.genderLabel.text = ""
            }
        }
        cell.createdAtLabel.text = dateformatter.stringFromDate(object.createdAt!)
        cell.authorLabel.text = object["author"] as? String
        var countComments = 0
        if let remoteCountComments = object["countComments"] as? NSNumber {
            countComments = remoteCountComments.integerValue
        }
        cell.commentsLabel.text = "\(countComments)"
        cell.delegate = self
        var countUpvotes = 0
        var countDownvotes = 0
        if let count = object[Constants.countUpvotes] as? NSNumber {
            countUpvotes = count.integerValue
        }
        if let count = object[Constants.countDownvotes] as? NSNumber {
            countDownvotes = count.integerValue
        }
        cell.setVoteButtonLabels(countUpvotes, deservCount: countDownvotes)
        
        if let postObjectId = object.objectId {
            if let kind = votes[postObjectId] {
                if kind == Constants.upvote {
                    cell.setSuxxsSelected()
                } else {
                    cell.setDeserveSelected()
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - PostCellDelegate
    
    func postCellDidTouchSuxxsButton(sender: PostCell) {
        saveVote(Constants.upvote, sender: sender)
    }
    
    func postCellDidTouchDeserveButton(sender: PostCell) {
        saveVote(Constants.downvote, sender: sender)
    }
    
    func postCellDidTouchComments(sender: PostCell) {
        let indexPath = tableView.indexPathForCell(sender)
        if let indexPath = indexPath {
            let postObject = dataSouce[indexPath.row]
            let vc = storyboard?.instantiateViewControllerWithIdentifier("CommentsViewController") as! CommentsViewController
            vc.postObject = postObject
            navigationController?.showViewController(vc, sender: self)
        } else {
            UIAlertController.showAlertWithTitle("error_missing_post_title".localizedString, message: "error_missing_post_message".localizedString, handler: { (action: UIAlertAction!) -> Void in
                
            })
        }
    }
    
    func postCellDidTouchShare(sender: PostCell) {
        let nib = NSBundle.mainBundle().loadNibNamed("ShareTemplate", owner: self, options: nil)
        let shareView = nib[0] as! ShareTemplate
        shareView.messageLabel.text = sender.messageLabel.text
        shareView.urlLabel.text = "share_url".localizedString
        let rect = shareView.bounds
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        shareView.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var sharingItems = [AnyObject]()
        sharingItems.append(image)
        let activityController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
}

