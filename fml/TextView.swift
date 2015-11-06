//
//  TextView.swift
//  fml
//
//  Created by Hanno Bruns on 06.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit
import SZTextView

class TextView: SZTextView {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.backgroundColor()
        textColor = UIColor.textColor()
    }

}
