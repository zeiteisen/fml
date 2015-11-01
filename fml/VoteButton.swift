//
//  VoteButton.swift
//  fml
//
//  Created by Hanno Bruns on 29.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

class VoteButton: UIButton {
    
    override var selected: Bool {
        willSet(newValue) {

        }
        
        didSet {
            if selected {
                backgroundColor = UIColor.mainColor()
                layer.borderWidth = 0
            } else {
                setButtonDefault()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setButtonDefault()
        setTitleColor(UIColor.mainColor(), forState: .Normal)
        setTitleColor(UIColor.complementColor(), forState: .Selected)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5
    }
    
    func setButtonDefault() {
        backgroundColor = UIColor.complementColor()
        layer.cornerRadius = 10
        layer.borderColor = UIColor.mainColor().CGColor
        layer.borderWidth = 1.0
    }

}
