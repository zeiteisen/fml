//
//  NSProcessInfo+Version.swift
//  fml
//
//  Created by Hanno Bruns on 03.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import Foundation

extension NSProcessInfo {
    class func iOS9OrGreater() -> Bool {
        return NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0))
    }
}