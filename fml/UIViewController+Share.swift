//
//  ShareHelper.swift
//  fml
//
//  Created by Hanno Bruns on 12.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

extension UIViewController {
    func shareImageWithMessage(message: String?, popoverSourceView: UIView) {
        let nib = NSBundle.mainBundle().loadNibNamed("ShareTemplate", owner: self, options: nil)
        let shareView = nib[0] as! ShareTemplate
        shareView.messageLabel.text = message
        shareView.urlLabel.text = "share_url".localizedString
        let rect = shareView.bounds
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        shareView.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var sharingItems = [AnyObject]()
        sharingItems.append(image)
        let activityController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = popoverSourceView
        presentViewController(activityController, animated: true, completion: nil)
    }
}
