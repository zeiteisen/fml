//
//  NSDate+Compare.swift
//  fml
//
//  Created by Hanno Bruns on 25.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import Foundation

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }
