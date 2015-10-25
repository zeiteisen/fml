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
    @IBOutlet weak var textView: SZTextView!
    @IBOutlet weak var saveButton: SmartButton!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.enabled = false
        textView.becomeFirstResponder()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
//    - (void)keyboardWillShow:(NSNotification *)notification{
//    NSDictionary* keyboardInfo = [notification userInfo];
//    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
//    self.textInputViewBottomContraint.constant = keyboardFrameEndRect.size.height;
//    [UIView animateWithDuration:.3 animations:^{
//    [self.view layoutIfNeeded];
//    }];
//    if ([self shouldScrollToBottom]) {
//    [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:.5];
//    }
//    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            textViewHeightConstraint.constant = ((view.frame.height - keyboardSize.height) - saveButton.frame.size.height)
            view.layoutIfNeeded()
        }
    }

    // MARK: - Actions
    
    @IBAction func saveTouched(sender: AnyObject) {
        let object = PFObject(className: "Comment")
        object["owner"] = PFUser.currentUser()
        object["post"] = postObject
        object["message"] = textView.text
        object["hidden"] = false
        postObject.incrementKey("countComments")
        postObject.saveEventually()
        object.saveEventually { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                UIAlertController.showAlertWithError(error)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
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
