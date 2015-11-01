//
//  NSBundle+Lang.swift
//  fml
//
//  Created by Hanno Bruns on 01.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

extension NSBundle {
    func getPrefrerredLang() -> String { // en_UK
        var lang = NSBundle.mainBundle().preferredLocalizations[0]
        lang = (lang as NSString).substringToIndex(2)
        return lang as String
    }
}