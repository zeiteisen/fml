//
//  ComposeViewController.swift
//  fml
//
//  Created by Hanno Bruns on 17.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit
import SZTextView

class ComposeViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: SZTextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: SmartButton!
    let model = NewFMLModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNextButtonEnabled(false)
        saveButton.enabled = false
        textView.becomeFirstResponder()
        automaticallyAdjustsScrollViewInsets = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            let constant = ((view.frame.height - keyboardSize.height) - saveButton.frame.size.height)
            textViewHeightConstraint.constant = constant  - textView.frame.origin.y
            view.layoutIfNeeded()
        }
    }

    @IBAction func closeTouched(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setNextButtonEnabled(enable: Bool) {
        navigationItem.rightBarButtonItem?.enabled = enable
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        model.message = textView.text
        // Get the new view controller using segue.destinationViewController.
        let vc = segue.destinationViewController as! AuthorViewController
        vc.model = model
        // Pass the selected object to the new view controller.
    }

    // MARK: - TextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        if textView.text.characters.count > 20 {
            setNextButtonEnabled(true)
            saveButton.enabled = true
        } else {
            setNextButtonEnabled(false)
            saveButton.enabled = false
        }
    }
    
}
