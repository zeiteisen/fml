//
//  SelectCategoryCell.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

class SelectCategoryCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.backgroundColor()
        var fontSize : CGFloat = 18.0
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            fontSize = 30.0
        }
        textLabel?.font = UIFont.systemFontOfSize(fontSize)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
