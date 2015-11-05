//
//  UIColor+Default.swift
//  fml
//
//  Created by Hanno Bruns on 29.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

extension UIColor {
    class func mainColor() -> UIColor {
        return UIColor(red: 0.094, green: 0.094, blue: 0.094, alpha: 1.00)
    }
    
    class func complementColor() -> UIColor {
        return UIColor(red: 0.910, green: 0.345, blue: 0.329, alpha: 1.00)
    }
    
    class func secondaryColor() -> UIColor {
        return UIColor(red: 0.996, green: 0.988, blue: 0.925, alpha: 1.00)
    }
}