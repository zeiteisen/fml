//
//  Label.swift
//  fml
//
//  Created by Hanno Bruns on 06.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

class Label: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textColor = UIColor.textColor()
    }

}
