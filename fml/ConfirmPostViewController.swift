//
//  ConfirmPostViewController.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

class ConfirmPostViewController: UIViewController {
    
    @IBOutlet weak var confirmPostMessageLabel: UILabel!
    @IBOutlet weak var closeButton: SmartButton!
    @IBOutlet weak var enablePushButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        title = "confirm_post_title".localizedString
        view.backgroundColor = UIColor.backgroundColor()
        closeButton.setTitle("close_button_title".localizedString, forState: .Normal)
        confirmPostMessageLabel.text = "confirm_post_message".localizedString
        enablePushButton.setTitle("enable_push_button".localizedString, forState: .Normal)
        if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
           enablePushButton.hidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func enablePushTouched(sender: AnyObject) {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func closeTouched(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
}
