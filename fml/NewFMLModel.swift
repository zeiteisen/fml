//
//  NewFMLModel.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import Foundation

enum Gender {
    case Unknown
    case Female
    case Male
}

enum Categories: String {
    case Unknown = "Unknown"
    case Love = "Love"
    case Animals = "Animals"
    case Money = "Money"
    case Kids = "Kids"
    case Work = "Work"
    case Health = "Health"
    case Intimacy = "Intimacy"
    case School = "School"
    case Miscellaneous = "Miscellaneous"
    
    static let allValues = [Love, Animals, Money, Kids, Work, Health, Intimacy, School, Miscellaneous]
}

class NewFMLModel {
    var message = ""
    var gender = Gender.Unknown
    var author = ""
    var category = Categories.Unknown
}