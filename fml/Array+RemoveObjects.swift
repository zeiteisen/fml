//
//  Array+RemoveObjects.swift
//  fml
//
//  Created by Hanno Bruns on 25.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}