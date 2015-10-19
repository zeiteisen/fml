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
    let model = NewFMLModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        textView.becomeFirstResponder()
        setNextButtonEnabled(false)
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
        } else {
            setNextButtonEnabled(false)
        }
    }
    
}
