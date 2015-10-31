//
//  PFConfig+Defaults.swift
//  fml
//
//  Created by Hanno Bruns on 25.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import Foundation
import Parse

extension PFConfig {
    class func getBackgroundRefreshTimeSeconds() -> Int {
        #if DEBUG
            return 5
        #else
        if let value = PFConfig.currentConfig()["BackgroundRefreshTimeSeconds"] as? NSNumber {
            return value.integerValue
        } else {
            return 30
        }
        #endif
    }
    
    class func getMinimumTextLength() -> Int {
        if let value = PFConfig.currentConfig()["MinimumTextLength"] as? NSNumber {
            return value.integerValue
        } else {
            return 20
        }
    }
}