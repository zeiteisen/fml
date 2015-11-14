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
import Reachability

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadNewPostsButton: UIButton!
    var dataSouce = [PFObject]()
    let refreshControl = UIRefreshControl()
    var timer: NSTimer?
    var viewjustloaded = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "PostCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "PostCell")
        let titleView = UIImageView(image: UIImage(named: "Icon"))
        titleView.contentMode = UIViewContentMode.ScaleAspectFit
        var rect = titleView.frame
        rect.size.height = (navigationController?.navigationBar.frame.height)!
        titleView.frame = rect
        titleView.bounds = CGRectInset(titleView.frame, 3.0, 3.0)
        navigationItem.titleView = titleView
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "pullToRefreshUpdateRemote", forControlEvents: .ValueChanged)
        VoteManager.sharedInstance
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
        if Defaults[.lastRemoteUpdated] == nil || viewjustloaded {
            if viewjustloaded {
                updateLocal(false, success: { () -> () in
                    self.updateRemote({ () -> () in
                        self.updateLocal(false, success: nil)
                    })
                })
            } else {
                updateRemote({ () -> () in
                    self.updateLocal(true, success: nil)
                })
            }
            viewjustloaded = false
        } else {
            updateLocal(false, success: { () -> () in
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
    
    func updateLoadNewPostsButtonState() {
        let countNew = Defaults[.countNewPosts]
        if countNew > 0 {
            loadNewPostsButton.hidden = false
            var title = "load_new_posts_button_title_singular".localizedString
            if countNew > 1 {
                title = "load_new_posts_button_title_plural".localizedString
            }

            title = title.stringByReplacingString("#count#", with: "\(countNew)")
            loadNewPostsButton.setTitle(title, forState: .Normal)
        } else {
            loadNewPostsButton.hidden = true
        }
    }
    
    func updateInBackground() {
        let reach = Reachability.reachabilityForInternetConnection()
        let networkStatus = reach.currentReachabilityStatus()
        if (networkStatus != .NotReachable) {
            self.updateRemote({ () -> () in
                if NSProcessInfo.iOS9OrGreater() {
                    self.updateLocal(false, success: nil)
                }
            })
        }
    }
    
    func pullToRefreshUpdateRemote() {
        updateRemote { () -> () in
            self.updateLocal(true, success: nil)
        }
    }
    
    func saveLastTableViewContentOffsetY() {
        Defaults[.lastTableViewContentOffsetY] = Double(tableView.contentOffset.y)
    }
    
    func didEnterBackground(notification: NSNotification) {
        saveLastTableViewContentOffsetY()
    }
    
    func updateLocal(showNewPosts: Bool, success: (() -> ())?) {
        let query = getQuery()
        query.addDescendingOrder("releaseDate")
        query.fromLocalDatastore()
        query.whereKeyExists("releaseDate")
        if !showNewPosts {
            var lastLocalUpdated = NSDate(timeIntervalSinceNow: 0)
            if let savedLastLocalUpdated = Defaults[.lastLocalUpdated] {
                lastLocalUpdated = savedLastLocalUpdated
            } else {
                Defaults[.lastLocalUpdated] = lastLocalUpdated
            }
            query.whereKey("releaseDate", lessThanOrEqualTo: lastLocalUpdated)
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
                if !NSProcessInfo.iOS9OrGreater() { // ios 8 bug fix
                    self.reloadData()
                }
                if let success = success {
                    success()
                }
            }
        }

    }
    
    func updateRemote(completion: (() -> ())?) {
        var lastUpdated = NSDate(timeIntervalSince1970: 0)
        if let storedLastUpdated = Defaults[.lastRemoteUpdated] {
            lastUpdated = storedLastUpdated
        }
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
                if objects.count > 0 {
                    // if lastRemoteUpdated is never set, than it's first load
                    if Defaults[.lastRemoteUpdated] != nil {
                        var newPosts = [PFObject]()
                        for newPost in objects {
                            if let releaseDate = newPost["releaseDate"] as? NSDate {
                                if releaseDate > lastUpdated {
                                    newPosts.append(newPost)
                                }
                            }
                        }
                        Defaults[.countNewPosts] += newPosts.count
                        self.showNewPostsIndicator(Defaults[.countNewPosts])
                    }
                    
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
                }
                print("delta update \(objects)")
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
    
    func saveVote(kind: String, sender: PostCell) {
        if let indexPath = tableView.indexPathForCell(sender) {
            let object = dataSouce[indexPath.row]
            VoteManager.sharedInstance.saveVote(kind, post: object, completion: { () -> () in
                self.reloadData()
            })
        }
    }
    
    // MARK: - Actions
    
    @IBAction func loadNewPostsTouched(sender: AnyObject) {
        updateLocal(true) { () -> () in
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
        cell.delegate = self
        let object = dataSouce[indexPath.row]
        if let postObjectId = object.objectId {
            cell.updateWithParseObject(object, voteKind: VoteManager.sharedInstance.votes[postObjectId])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PostCell
        postCellDidTouchComments(cell)
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
        shareImageWithMessage(sender.messageLabel.text, author: sender.authorLabel.text, popoverSourceView: sender.shareButton)
    }
}

