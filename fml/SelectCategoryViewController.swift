//
//  SelectCategoryViewController.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit
import Parse

class SelectCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var model: NewFMLModel!
    @IBOutlet weak var postButton: SmartButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    let dataSource = Categories.allValues
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundColor()
        tableView.backgroundColor = UIColor.backgroundColor()
        postButton.enabled = false
        nextBarButton.enabled = false
        title = "select_category_title".localizedString
        let nextTitle = "select_category_next_title".localizedString
        nextBarButton.title = nextTitle
        postButton.setTitle(nextTitle, forState: .Normal)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Actions

    @IBAction func postTouched(sender: AnyObject) {
        let object = PFObject(className: "Post")
        object["author"] = model.author
        if model.gender == .Female {
            object["female"] = true
        } else {
            object["female"] = false
        }
        object["category"] = model.category.rawValue
        object["message"] = model.message
        object["owner"] = PFUser.currentUser()
        object["hidden"] = true
        object["moderation"] = "pending"
        object["countComments"] = 0
        object["countUpvotes"] = 0
        object["countDownvotes"] = 0
        object["lang"] = NSBundle.mainBundle().getPrefrerredLang()
        postButton.enabled = false
        nextBarButton.enabled = false
        object.saveEventually()
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ConfirmPostViewController") as! ConfirmPostViewController
        self.navigationController?.showViewController(vc, sender: self)
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectCategoryCell") as! SelectCategoryCell
        cell.textLabel?.text = dataSource[indexPath.row].rawValue.localizedString
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        model.category = dataSource[indexPath.row]
        postButton.enabled = true
        nextBarButton.enabled = true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}
