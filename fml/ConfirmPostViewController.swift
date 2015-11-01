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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        title = "confirm_post_title".localizedString
        closeButton.setTitle("close_button_title".localizedString, forState: .Normal)
        confirmPostMessageLabel.text = "confirm_post_message".localizedString
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeTouched(sender: AnyObject) {
        if let navController = self.presentingViewController as? UINavigationController {
            if let vc = navController.viewControllers[0] as? ViewController {
                vc.loadPosts(true, keepScrollPosition: false, success: nil)
            }
        }
        presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
}
