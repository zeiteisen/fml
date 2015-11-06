//
//  WriteCommentViewController.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit
import Parse
import SZTextView

class WriteCommentViewController: UIViewController, UITextViewDelegate {

    var postObject: PFObject!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var textView: SZTextView!
    @IBOutlet weak var saveButton: SmartButton!
//    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundColor()
        title = "write_comment_title".localizedString
        saveButton.setTitle("save_comment_button_title".localizedString, forState: .Normal)
        saveBarButton.title = "save_comment_button_title".localizedString
        saveButton.enabled = false
        textView.becomeFirstResponder()
        textView.placeholder = "write_comment_placeholder".localizedString
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            bottomConstraint.constant = keyboardSize.height
            view.layoutIfNeeded()
            
//            textViewHeightConstraint.constant = ((view.frame.height - keyboardSize.height) - saveButton.frame.size.height)
//            view.layoutIfNeeded()
        }
    }

    // MARK: - Actions
    
    @IBAction func saveTouched(sender: AnyObject) {
        let object = PFObject(className: "Comment")
        object["owner"] = PFUser.currentUser()
        object["post"] = postObject
        object["message"] = textView.text
        object["hidden"] = false
        object["rating"] = 0
        if let author = PFUser.currentUser()![Constants.author] as? String {
            object[Constants.author] = author
        }
        postObject.incrementKey("countComments")
        postObject.saveEventually()
        object.pinInBackground()
        saveButton.enabled = false
        object.saveEventually { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                UIAlertController.showAlertWithError(error)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
            self.saveButton.enabled = true
        }
    }
    
    // MARK: - TextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        if textView.text.characters.count > 2 {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }
    }
}
