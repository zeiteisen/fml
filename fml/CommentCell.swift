//
//  CommentCell.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

protocol CommentCellDelegate {
    func commentCellDidTouchUpvote(sender: CommentCell)
    func commentCellDidTouchDownvote(sender: CommentCell)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    var delegate: CommentCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if !NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)) { // iOS 8 bug fix
            messageLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 50
        }
        backgroundColor = UIColor.backgroundColor()
    }
    
    @IBAction func upvoteTouched(sender: AnyObject) {
        delegate?.commentCellDidTouchUpvote(self)
    }

    
    @IBAction func downvoteTouched(sender: AnyObject) {
        delegate?.commentCellDidTouchDownvote(self)
    }
}
