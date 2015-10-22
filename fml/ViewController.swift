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
        refreshControl.addTarget(self, action: "updateRemote", forControlEvents: .ValueChanged)
        if Defaults[.lastUpdated] == nil {
            loadPosts(false, success: nil)
        } else {
            loadPosts(true, success: { () -> () in
                self.delay(5) {
                    self.updateRemote()
                }
            })
        }
    }
    
    func loadPosts(locally: Bool, success: (() -> ())?) {
        let query = PFQuery(className: Constants.parsePostClassName)
        query.addDescendingOrder("createdAt")
        if locally {
            query.fromLocalDatastore()
        }
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                UIAlertController.showAlertWithError(error)
            } else if let objects = objects {
                if !locally {
                    Defaults[.lastUpdated] = NSDate(timeIntervalSinceNow: 0)
                }
                PFObject.pinAllInBackground(objects)
                self.dataSouce = objects
                self.tableView.reloadData()
                if let success = success {
                    success()
                }
            }
        }
    }
    
    func updateRemote() {
        if let lastUpdated = Defaults[.lastUpdated] {
            let query = PFQuery(className: Constants.parsePostClassName)
            query.whereKey("updatedAt", greaterThan: lastUpdated)
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                self.refreshControl.endRefreshing()
                if let error = error {
                    UIAlertController.showAlertWithError(error)
                } else if let objects = objects {
                    Defaults[.lastUpdated] = NSDate(timeIntervalSinceNow: 0)
                    PFObject.pinAllInBackground(objects, block: { (success: Bool, error: NSError?) -> Void in
                        if let error = error {
                            UIAlertController.showAlertWithError(error)
                        } else {
                            self.loadPosts(true, success: { () -> () in
                            })
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

    // MARK: - TableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSouce.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        let object = dataSouce[indexPath.row]
        cell.messageLabel.text = object["message"] as? String
        cell.authorLabel.text = object["author"] as? String
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

