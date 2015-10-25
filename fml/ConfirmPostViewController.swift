//
//  ConfirmPostViewController.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

class ConfirmPostViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
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
