//
//  AuthorViewController.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit
import Parse

class AuthorViewController: UIViewController {
    
    var model: NewFMLModel!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    let user = PFUser.currentUser()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let author = user["author"] as? String {
            authorTextField.text = author
        }
        if let female = user["female"] as? NSNumber {
            if female.boolValue {
                genderSegment.selectedSegmentIndex = 0
            } else {
                genderSegment.selectedSegmentIndex = 1
            }
        } else {
            genderSegment.selectedSegmentIndex = UISegmentedControlNoSegment
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if genderSegment.selectedSegmentIndex == 0 {
            model.gender = .Female
            user["female"] = true
        } else {
            model.gender = .Male
            user["female"] = false
        }
        model.author = authorTextField.text!
        user["author"] = model.author
        user.saveInBackground()
        // Get the new view controller using segue.destinationViewController.
        let vc = segue.destinationViewController as! SelectCategoryViewController
        vc.model = model
        // Pass the selected object to the new view controller.
    }

}
