//
//  UpvoteView.swift
//  fml
//
//  Created by Hanno Bruns on 09.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

@IBDesignable class VoteView : NibDesignable {

    @IBOutlet weak var fImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var countVotesBackgroundView: UIView!
    @IBOutlet weak var countVotesLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        countVotesLabel.textColor = UIColor.backgroundColor()
        backgroundColor = UIColor.clearColor()
        layer.cornerRadius = 5
    }
    
    func resetView() {
        userInteractionEnabled = true
        button.selected = false
        countVotesBackgroundView.backgroundColor = UIColor.textColor()
        if let imageView = fImageView {
            imageView.tintColor = UIColor.textColor()
        }
        label.textColor = UIColor.textColor()
        layer.borderColor = UIColor.textColor().CGColor
        layer.borderWidth = 2
        labelBackgroundView.backgroundColor = UIColor.backgroundColor()
    }
    
    func selectView() {
        userInteractionEnabled = false
        button.selected = false
        countVotesBackgroundView.backgroundColor = UIColor.accentColor()
        fImageView.tintColor = UIColor.backgroundColor()
        label.textColor = UIColor.backgroundColor()
        layer.borderColor = UIColor.textColor().CGColor
        layer.borderWidth = 0
        labelBackgroundView.backgroundColor = UIColor.textColor()
    }
    
    func disableView() {
        userInteractionEnabled = false
        alpha = 0.5
    }
    
    func setHighlighted() {
        alpha = 0.5
    }
    
    func setNormal() {
        alpha = 1
    }
    
    @IBAction func touchUpOutside(sender: AnyObject) {
        setNormal()
    }
    
    @IBAction func touchUpInside(sender: AnyObject) {
        setNormal()
    }
    
    @IBAction func touchDown(sender: AnyObject) {
        setHighlighted()
    }
    
    @IBAction func touchCancel(sender: AnyObject) {
        setNormal()
    }
    
    @IBAction func touchDragExit(sender: AnyObject) {
        setNormal()
    }
    
    @IBAction func touchDragEnter(sender: AnyObject) {
        setHighlighted()
    }
}
