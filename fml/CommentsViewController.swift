//
//  CommentsViewController.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit
import Parse

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var postObject: PFObject!
    var dataSouce = [PFObject]()
    let dateFormatter = NSDateFormatter()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        refreshControl.addTarget(self, action: "pullToRefreshUpdateRemote", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        if let headerView = tableView.tableHeaderView as? CommentTableHeaderView {
            headerView.label.text = postObject["message"] as? String
        }
        loadComments(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadComments(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderForFit()
    }
    
    func pullToRefreshUpdateRemote() {
        loadComments(false)
    }
    
    func loadComments(locally: Bool) {
        // TODO maybe add a timestamp and query only for updatedAt. Save the posts objectId as key and the date as value
        let query = PFQuery(className: "Comment")
        if locally {
            query.fromLocalDatastore()
        }
        query.whereKey("post", equalTo: postObject)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            self.refreshControl.endRefreshing()
            if let error = error {
                UIAlertController.showAlertWithError(error)
            } else if let objects = objects {
                PFObject.pinAllInBackground(objects)
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
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! WriteCommentViewController
        vc.postObject = postObject
    }

    // MARK: - TableView
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        let object = dataSouce[indexPath.row]
        cell.messageLabel.text = object["message"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count
    }
}
