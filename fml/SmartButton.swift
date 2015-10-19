import UIKit

class SmartButton: UIButton {
    var originalBackgroundColor = UIColor.blueColor() // make it blue so the bug is visible
    
    override func awakeFromNib() {
        titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        titleLabel?.textAlignment = NSTextAlignment.Center
//        layer.cornerRadius = 10
        if let foo = backgroundColor {
            originalBackgroundColor = foo
        } else {
            print("foo")
        }
    }
    
    override var enabled: Bool {
        willSet(newValue) {
            if newValue {
                backgroundColor = originalBackgroundColor
            } else {
                backgroundColor = originalBackgroundColor.colorWithAlphaComponent(0.5)
            }
        }
    }
    
    override var highlighted: Bool {
        willSet(newValue) {
            if newValue {
                backgroundColor = originalBackgroundColor.colorWithAlphaComponent(0.5)
            } else {
                backgroundColor = originalBackgroundColor
            }
        }
        
        didSet {
            
        }
    }
}
