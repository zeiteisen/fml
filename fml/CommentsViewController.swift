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

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommentCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var postObject: PFObject!
    var dataSouce = [PFObject]()
    let dateFormatter = NSDateFormatter()
    var refreshControl = UIRefreshControl()
    let dateformatter = NSDateFormatter()
    var votes = [PFObject : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        dateformatter.dateStyle = .LongStyle
        refreshControl.addTarget(self, action: "pullToRefreshUpdateRemote", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        if let headerView = tableView.tableHeaderView as? CommentTableHeaderView {
            headerView.label.text = postObject["message"] as? String
        }
        updateVotesArray()
        updateRemoteComments { () -> () in
            self.updateLocalComments()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateVotesArray()
        updateLocalComments()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderForFit()
    }
    
    func pullToRefreshUpdateRemote() {
        updateRemoteComments { () -> () in
            self.updateLocalComments()
        }
    }
    
    func getCommentsQuery() -> PFQuery {
        let query = PFQuery(className: "Comment")
        query.whereKey("post", equalTo: postObject)
//        query.orderByDescending("createdAt")
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
                PFObject.pinAllInBackground(objects)
                if let postObjectId = self.postObject.objectId {
                    Defaults[Constants.lastRemoteCommentUpdatePrefix + postObjectId] = NSDate(timeIntervalSinceNow: 0)
                }
                completion?()
            }
        }
    }
    
    func updateLocalComments() {
        let query = getCommentsQuery()
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                self.dataSouce = objects
                self.tableView.reloadData()
            }
        }
    }
    
    func sizeHeaderForFit() {
        let headerView = tableView.tableHeaderView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        tableView.tableHeaderView = headerView
    }
    
    func saveVote(kind: String, sender: CommentCell) {
        if let indexPath = tableView.indexPathForCell(sender) {
            let commentObject = dataSouce[indexPath.row]
            votes[commentObject] = kind
            if kind == Constants.upvote {
                commentObject.incrementKey(Constants.commentsRating)
            } else {
                commentObject.incrementKey(Constants.commentsRating, byAmount: -1)
            }
            commentObject.saveEventually()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        cell.delegate = self
        let object = dataSouce[indexPath.row]
        var rating = 0
        if let remoteRating = object[Constants.commentsRating] as? NSNumber {
            rating = remoteRating.integerValue
        }
        cell.ratingLabel.text = "\(rating)"
        cell.messageLabel.text = object["message"] as? String
        var author = "anonymous".localizedString
        if let remoteAuthor = object[Constants.author] as? String {
            author = remoteAuthor
        }
        cell.authorLabel.text = author
        cell.dateLabel.text = dateformatter.stringFromDate(object.createdAt!)
        
        cell.upvoteButton.userInteractionEnabled = true
        cell.downvoteButton.userInteractionEnabled = true
        cell.upvoteButton.selected = false
        cell.downvoteButton.selected = false
        if let kind = votes[object] {
            cell.upvoteButton.userInteractionEnabled = false
            cell.downvoteButton.userInteractionEnabled = false
            if kind == Constants.upvote {
                cell.upvoteButton.selected = true
            } else {
                cell.downvoteButton.selected = true
            }
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
