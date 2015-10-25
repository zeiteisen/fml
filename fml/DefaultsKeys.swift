//
//  DefaultsKeys.swift
//  fml
//
//  Created by Hanno Bruns on 22.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {
    static let lastRemoteUpdated = DefaultsKey<NSDate?>(Constants.lastRemoteUpdatedDateKey)
    static let lastLocalUpdated = DefaultsKey<NSDate?>(Constants.lastLocalUpdatedDateKey)
    static let countNewPosts = DefaultsKey<Int>(Constants.countNewPosts)
    static let lastTableViewContentOffsetY = DefaultsKey<Double>(Constants.lastTableViewContentOffsetY)
}