//
//  RoundCornerView.swift
//  fml
//
//  Created by Hanno Bruns on 21.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

class RoundCornerView : UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}