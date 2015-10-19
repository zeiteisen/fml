import UIKit

extension UIAlertController {
    class func showAlertWithTitle(title: String, message: String, handler: ((UIAlertAction!) -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default, handler: handler)
        alert.addAction(action)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func showAlertWithError(error: NSError) {
        let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: error.localizedDescription, preferredStyle: .Alert)
        let action = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .Default) { (action: UIAlertAction) -> Void in
            
        }
        alert.addAction(action)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
}
