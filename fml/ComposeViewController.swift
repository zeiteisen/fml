//
//  ComposeViewController.swift
//  fml
//
//  Created by Hanno Bruns on 17.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit
import SZTextView
import Parse

class ComposeViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: SZTextView!
    @IBOutlet weak var saveButton: SmartButton!
    @IBOutlet weak var countLettersLabel: UILabel!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    let model = NewFMLModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "compose_title".localizedString
        view.backgroundColor = UIColor.backgroundColor()
        let nextButtonTitle = "compose_next_button_title".localizedString;
        saveButton.setTitle(nextButtonTitle, forState: .Normal)
        nextBarButton.title = nextButtonTitle
        textView.placeholder = "compose_textview_placeholder".localizedString
        setNextButtonEnabled(false)
        saveButton.enabled = false
        updateLetterCountLabel()
        automaticallyAdjustsScrollViewInsets = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            bottomConstraint.constant = keyboardSize.height
            view.layoutIfNeeded()
        }
    }
    
    func updateLetterCountLabel() {
        let count = textView.text.characters.count
        let min = PFConfig.getMinimumTextLength()
        if count > min {
            countLettersLabel.textColor = UIColor.textColor()
        } else {
            countLettersLabel.textColor = UIColor.lightGrayColor()
        }
        countLettersLabel.text = "\(count) > \(min)"
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
        updateLetterCountLabel()
        if textView.text.characters.count > PFConfig.getMinimumTextLength() {
            setNextButtonEnabled(true)
            saveButton.enabled = true
        } else {
            setNextButtonEnabled(false)
            saveButton.enabled = false
        }
    }
    
}
