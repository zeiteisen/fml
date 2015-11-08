//
//  CommentsViewController.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit
import Parse
import SwiftyUserDefaults

class CommentModel {
    var parseObject: PFObject!
    var reuseIdentifier: String!
}

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommentCellDelegate {

    @IBOutlet weak var writeCommentBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentButton: SmartButton!
    var postObject: PFObject!
    var dataSouce = [CommentModel]()
    var refreshControl = UIRefreshControl()
    let dateformatter = NSDateFormatter()
    var votes = [PFObject : String]()
    var viewjustloaded = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "PostCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "PostCell")
        title = "comments_title".localizedString
        view.backgroundColor = UIColor.backgroundColor()
        commentButton.setTitle("write_comment_button_title".localizedString, forState: .Normal);
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        refreshControl.addTarget(self, action: "pullToRefreshUpdateRemote", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        updateVotesArray()
        updateRemoteComments { () -> () in
            self.updateLocalComments()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshControl.superview?.sendSubviewToBack(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !viewjustloaded {
            updateVotesArray()
            updateLocalComments()
        } else {
            viewjustloaded = false
        }
    }
    
    func pullToRefreshUpdateRemote() {
        updateRemoteComments { () -> () in
            self.updateLocalComments()
        }
    }
    
    func getCommentsQuery() -> PFQuery {
        let query = PFQuery(className: "Comment")
        query.whereKey("post", equalTo: postObject)
        query.orderByDescending(Constants.commentsRating)
        return query
    }
    
    func updateRemoteComments(completion: (() -> ())?) {
        let query = getCommentsQuery()
        if let postObjectId = postObject.objectId {
            if let lastUpdated = Defaults.objectForKey(Constants.lastRemoteCommentUpdatePrefix + postObjectId) as? NSDate {
                query.whereKey("updatedAt", greaterThan: lastUpdated)
            }
        }
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            self.refreshControl.endRefreshing()
            if let error = error {
                UIAlertController.showAlertWithError(error)
            } else if let objects = objects {
                print("new comments \(objects)")
                if let postObjectId = self.postObject.objectId {
                    Defaults[Constants.lastRemoteCommentUpdatePrefix + postObjectId] = NSDate(timeIntervalSinceNow: 0)
                }
                PFObject.pinAllInBackground(objects, block: { (success: Bool, error: NSError?) -> Void in
                    if let error = error {
                        print("error pinning new comments \(error)")
                    } else {
                        completion?()
                    }
                })
            }
        }
    }
    
    func updateLocalComments() {
        let query = getCommentsQuery()
        query.whereKey("hidden", equalTo: NSNumber(bool: false))
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                if objects.count == 0 { // no local comments, reset the last updated at
                    if let postObjectId = self.postObject.objectId {
                        Defaults[Constants.lastRemoteCommentUpdatePrefix + postObjectId] = NSDate(timeIntervalSinceReferenceDate: 0)
                    }
                }
                
                self.dataSouce.removeAll()
                let model = CommentModel()
                model.parseObject = self.postObject
                model.reuseIdentifier = "PostCell"
                self.dataSouce.append(model)
                for object in objects {
                    let model = CommentModel()
                    model.parseObject = object
                    model.reuseIdentifier = "CommentCell"
                    self.dataSouce.append(model)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func saveVote(kind: String, sender: CommentCell) {
        if let indexPath = tableView.indexPathForCell(sender) {
            let commentObject = dataSouce[indexPath.row]
            votes[commentObject.parseObject] = kind
            if kind == Constants.upvote {
                commentObject.parseObject.incrementKey(Constants.commentsRating)
            } else {
                commentObject.parseObject.incrementKey(Constants.commentsRating, byAmount: -1)
            }
            commentObject.parseObject.saveEventually()
            let voteObject = PFObject(className: "Vote")
            voteObject["owner"] = PFUser.currentUser()
            voteObject["comment"] = commentObject
            voteObject["post"] = postObject
            voteObject["kind"] = kind
            voteObject.pinInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    self.tableView.reloadData()
                }
            })
            voteObject.saveEventually()
        }
    }
    
    func updateVotesArray() {
        let query = PFQuery(className: "Vote")
        query.whereKeyExists("comment")
        query.whereKey("post", equalTo: postObject)
        query.fromLocalDatastore()
        query.limit = 1000 // TODO add support for more than 1000 votes
        query.findObjectsInBackgroundWithBlock { (votes: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("searching local vote failed: \(error)")
            } else if let votes = votes {
                self.votes.removeAll()
                for vote in votes {
                    let voteComment = vote["comment"] as! PFObject
                    self.votes[voteComment] = vote["kind"] as? String
                }
            }
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! WriteCommentViewController
        vc.postObject = postObject
    }

    // MARK: - TableView
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object = dataSouce[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(object.reuseIdentifier, forIndexPath: indexPath)
        if let postCell = cell as? PostCell {
//            postCell.delegate = self
            postCell.updateWithParseObject(object.parseObject, voteKind: "")
        } else if let commentCell = cell as? CommentCell {
            commentCell.delegate = self
            commentCell.updateWithParseObject(object.parseObject, upvoteKind: votes[object.parseObject])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count
    }
    
    // MARK: - CommentCellDelegate
    
    func commentCellDidTouchUpvote(sender: CommentCell) {
        saveVote(Constants.upvote, sender: sender)
    }
    
    func commentCellDidTouchDownvote(sender: CommentCell) {
        saveVote(Constants.downvote, sender: sender)
    }
}
