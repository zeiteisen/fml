//
//  SegmentedControl.swift
//  fml
//
//  Created by Hanno Bruns on 06.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

class SegmentedControl: UISegmentedControl {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = UIColor.textColor()
        var fontSize : CGFloat = 14.0
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            fontSize = 30.0
        }
        let font = UIFont.systemFontOfSize(fontSize)
        let attributes = [NSFontAttributeName : font]
        setTitleTextAttributes(attributes, forState: .Normal)
    }
    
}
