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
    let dateformatter = NSDateFormatter()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        dateformatter.dateStyle = .LongStyle
        dateformatter.locale = NSLocale(localeIdentifier: NSLocale.preferredLanguages()[0])
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "pullToRefreshUpdateRemote", forControlEvents: .ValueChanged)
        if Defaults[.lastRemoteUpdated] == nil {
            loadPosts(false, keepScrollPosition: false, success: nil)
        } else {
            loadPosts(true, keepScrollPosition: true, success: { () -> () in
                self.tableView.contentOffset.y = CGFloat(Defaults[.lastTableViewContentOffsetY])
            })
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "updateInBackground", userInfo: nil, repeats: true)
        updateLoadNewPostsButtonState()
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
        let query = PFQuery(className: Constants.parsePostClassName)
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
                self.tableView.reloadData()
                if !locally {
                    Defaults[.lastLocalUpdated] = NSDate(timeIntervalSinceNow: 0)
                }
                if let success = success {
                    success()
                }
            }
        }
    }
    
    func showNewPostsIndicator(count: Int) {
        updateLoadNewPostsButtonState()
    }
    
    func updateRemote(completion: (() -> ())?) {
        if let lastUpdated = Defaults[.lastRemoteUpdated] {
            let query = PFQuery(className: Constants.parsePostClassName)
            query.whereKey("updatedAt", greaterThan: lastUpdated)
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                self.refreshControl.endRefreshing()
                if let error = error {
                    UIAlertController.showAlertWithError(error)
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
        cell.messageLabel.text = object["message"] as? String
        cell.authorLabel.text = object["author"] as? String
        var countComments = 0
        if let remoteCountComments = object["countComments"] as? NSNumber {
            countComments = remoteCountComments.integerValue
        }
        cell.commentsLabel.text = "\(countComments)"
        cell.createdAtLabel.text = dateformatter.stringFromDate(object.createdAt!)
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - PostCellDelegate
    
    func postCellDidTouchSuxxsButton(sender: PostCell) {
        
    }
    
    func postCellDidTouchDeserveButton(sender: PostCell) {
        
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
        
    }
}

