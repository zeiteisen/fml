//
//  RoundTopCornerView.swift
//  fml
//
//  Created by Hanno Bruns on 08.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

class RoundTopCornerView: UIView {
    
    override func layoutSubviews() {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: UIRectCorner.TopLeft.union(.TopRight), cornerRadii: CGSizeMake(10, 10)).CGPath
        layer.mask = maskLayer
    }
}
