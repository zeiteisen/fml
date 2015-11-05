//
//  FontAwesomeLabel.swift
//  fml
//
//  Created by Hanno Bruns on 04.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

class FontAwesomeLabel : UILabel {
    
    @IBInspectable var iPhoneFontSize: CGFloat = 14.0
    @IBInspectable var iPadFontSize: CGFloat = 20.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            font = UIFont(name: "FontAwesome", size: iPadFontSize)
        } else {
            font = UIFont(name: "FontAwesome", size: iPhoneFontSize)
        }
    }
}