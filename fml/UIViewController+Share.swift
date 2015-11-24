//
//  ShareHelper.swift
//  fml
//
//  Created by Hanno Bruns on 12.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit
import Parse

extension UIViewController {
    func shareImageWithMessage(message: String?, author: String?, popoverSourceView: UIView, gender: String?) {
        let nib = NSBundle.mainBundle().loadNibNamed("ShareTemplate", owner: self, options: nil)
        let shareView = nib[0] as! ShareTemplate
        var author2 = "anonymous".localizedString
        if author != nil {
            author2 = author!
        }
        shareView.messageLabel.text = message! + "\n\n– " + author2
        let rect = shareView.bounds
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        shareView.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var sharingItems = [AnyObject]()
        sharingItems.append(image)
        if let url = NSURL(string: "share_url".localizedString) {
            sharingItems.append(url)
        }
        let activityController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        activityController.completionWithItemsHandler = { (activity: String?, success: Bool, items: [AnyObject]?, error: NSError?) in
            var dimensions = [ "text" : message!]
            if let activity = activity {
                dimensions["activity"] = activity
            }
            if success {
                dimensions["success"] = "true"
            } else {
                dimensions["success"] = "false"
            }
            PFAnalytics.trackEvent("share", dimensions: dimensions)
        }
        activityController.popoverPresentationController?.sourceView = popoverSourceView
        presentViewController(activityController, animated: true, completion: nil)
    }
}
