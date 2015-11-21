//
//  ShareTemplate.swift
//  fml
//
//  Created by Hanno Bruns on 28.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

class ShareTemplate: UIView {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var genderLabel: GenderLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        urlLabel.text = "share_url".localizedString
        let random = arc4random_uniform(9)
        imageView.image = UIImage(named: "face_\(random).png")
    }
}
