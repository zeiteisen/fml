//
//  CommentCell.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit
import Parse

protocol CommentCellDelegate {
    func commentCellDidTouchUpvote(sender: CommentCell)
    func commentCellDidTouchDownvote(sender: CommentCell)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    var delegate: CommentCellDelegate?
    let dateFormatter = NSDateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if !NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)) { // iOS 8 bug fix
            messageLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 50
        }
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        dateFormatter.dateStyle = .LongStyle
        containerView.layer.cornerRadius = 5
    }
    
    func updateWithParseObject(object: PFObject, upvoteKind: String?) {
        var rating = 0
        if let remoteRating = object[Constants.commentsRating] as? NSNumber {
            rating = remoteRating.integerValue
        }
        ratingLabel.text = "\(rating)"
        messageLabel.text = object["message"] as? String
        var author = "anonymous".localizedString
        if let remoteAuthor = object[Constants.author] as? String {
            author = remoteAuthor
        }
        authorLabel.text = author
        dateLabel.text = dateFormatter.stringFromDate(object.createdAt!)
        
        upvoteButton.userInteractionEnabled = false
        downvoteButton.userInteractionEnabled = false
        upvoteButton.selected = false
        downvoteButton.selected = false
        if upvoteKind == Constants.upvote {
            upvoteButton.selected = true
        } else if upvoteKind == Constants.downvote {
            downvoteButton.selected = true
        } else {
            upvoteButton.userInteractionEnabled = true
            downvoteButton.userInteractionEnabled = true
        }
    }

    @IBAction func upvoteTouched(sender: AnyObject) {
        delegate?.commentCellDidTouchUpvote(self)
    }

    
    @IBAction func downvoteTouched(sender: AnyObject) {
        delegate?.commentCellDidTouchDownvote(self)
    }
}
