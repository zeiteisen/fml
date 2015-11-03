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
    @IBOutlet weak var nextButton: SmartButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    let user = PFUser.currentUser()!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorLabel.text = "author_label".localizedString
        genderLabel.text = "gender_label".localizedString
        genderSegment.setTitle("segment_female".localizedString, forSegmentAtIndex: 0)
        genderSegment.setTitle("segment_male".localizedString, forSegmentAtIndex: 1)
        title = "author_title".localizedString
        authorTextField.placeholder = "autor_textfield_placeholder".localizedString
        let nextButtonTitle = "author_next_button_title".localizedString
        nextButton.setTitle(nextButtonTitle, forState: .Normal)
        nextBarButton.title = nextButtonTitle
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
        setNextButtonState()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChange", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        authorTextField.becomeFirstResponder()
        if !NSProcessInfo.iOS9OrGreater() {
            delay(1) {
                self.authorTextField.resignFirstResponder()
                self.authorTextField.becomeFirstResponder()
            }
        }
    }
    
    func setNextButtonState() {
        if genderSegment.selectedSegmentIndex != UISegmentedControlNoSegment && authorTextField.text?.characters.count > 0 {
            nextButton.enabled = true
            nextBarButton.enabled = true
        } else {
            nextButton.enabled = false
            nextBarButton.enabled = false
        }
    }
    
    func textFieldDidChange() {
        setNextButtonState()
    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            bottomConstraint.constant = keyboardSize.height
            view.layoutIfNeeded()
        }
    }

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
        let vc = segue.destinationViewController as! SelectCategoryViewController
        vc.model = model
    }

    // MARK: - Actions
    
    @IBAction func didPickGender(sender: AnyObject) {
        setNextButtonState()
    }
}
