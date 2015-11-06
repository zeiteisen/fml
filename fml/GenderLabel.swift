//
//  RedAwesomeLabel.swift
//  fml
//
//  Created by Hanno Bruns on 06.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

class GenderLabel: FontAwesomeLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        textColor = UIColor.accentColor()
    }
}
