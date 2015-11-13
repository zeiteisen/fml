//
//  PostCell.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit
import Parse

protocol PostCellDelegate {
    func postCellDidTouchSuxxsButton(sender: PostCell)
    func postCellDidTouchDeserveButton(sender: PostCell)
    func postCellDidTouchShare(sender: PostCell)
    func postCellDidTouchComments(sender: PostCell)
}

class PostCell: UITableViewCell {

    @IBOutlet weak var suxxsButton: VoteView!
    @IBOutlet weak var deserveItButton: VoteView!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    var delegate: PostCellDelegate?
    var didVote = false
    let dateformatter = NSDateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
        if !NSProcessInfo.iOS9OrGreater() {
            messageLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 24
        }
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        suxxsButton.label.text = "suxxs_button_title".localizedString
        deserveItButton.label.text = "deserve_button_title".localizedString
        
        suxxsButton.button.addTarget(self, action: "suxxsTouched:", forControlEvents: .TouchUpInside)
        deserveItButton.button.addTarget(self, action: "deserveTouched:", forControlEvents: .TouchUpInside)
        
        deserveItButton.fImageView?.removeFromSuperview()
        
        layer.masksToBounds = false
        layer.shadowOffset = CGSizeMake(1, 1)
        layer.shadowRadius = 1
        layer.shadowColor = UIColor.textColor().CGColor
        layer.shadowOpacity = 0.5
        
        shareButton.imageView?.contentMode = .ScaleAspectFit
        commentsButton.imageView?.contentMode = .ScaleAspectFit
        
        dateformatter.dateStyle = .LongStyle
        dateformatter.locale = NSLocale(localeIdentifier: NSLocale.preferredLanguages()[0])
        
        resetState()
    }

    func updateWithParseObject(object: PFObject, voteKind: String?) {
        resetState()
        messageLabel.text = object["message"] as? String
        var author = object["author"] as? String
        if author == nil {
            author = "anonymous".localizedString
        }
        if let female = object["female"] as? NSNumber {
            if female.boolValue {
                genderLabel.text = ""
            } else {
                genderLabel.text = ""
            }
        }
        var releaseDate = NSDate(timeIntervalSince1970: 0)
        if let realReleaseDate = object["releaseDate"] as? NSDate {
            releaseDate = realReleaseDate
        }
        createdAtLabel.text = dateformatter.stringFromDate(releaseDate)
        authorLabel.text = object["author"] as? String
        var countComments = 0
        if let remoteCountComments = object["countComments"] as? NSNumber {
            countComments = remoteCountComments.integerValue
        }
        commentsLabel.text = "\(countComments)"
        var countUpvotes = 0
        var countDownvotes = 0
        if let count = object[Constants.countUpvotes] as? NSNumber {
            countUpvotes = count.integerValue
        }
        if let count = object[Constants.countDownvotes] as? NSNumber {
            countDownvotes = count.integerValue
        }
        setVoteButtonLabels(countUpvotes, deservCount: countDownvotes)
        if voteKind == Constants.upvote {
            setSuxxsSelected()
        } else if voteKind == Constants.downvote {
            setDeserveSelected()
        }
    }

    func resetState() {
        didVote = false
        suxxsButton.resetView()
        deserveItButton.resetView()
    }
    
    func setVoteButtonLabels(suxxsCount: Int, deservCount: Int) {
        suxxsButton.countVotesLabel.text = "\(suxxsCount)"
        deserveItButton.countVotesLabel.text = "\(deservCount)"
    }
    
    func setSuxxsSelected() {
        didVote = true
        suxxsButton.selectView()
        deserveItButton.disableView()
    }
    
    func setDeserveSelected() {
        didVote = true
        deserveItButton.selectView()
        suxxsButton.disableView()
    }

    // MARK: - Actions
    
    @IBAction func didTouchShare(sender: AnyObject) {
        delegate?.postCellDidTouchShare(self)
    }
    
    @IBAction func commentsTouched(sender: AnyObject) {
        delegate?.postCellDidTouchComments(self)
    }
    
    @IBAction func deserveTouched(sender: AnyObject) {
        if !didVote {
            setDeserveSelected()
            delegate?.postCellDidTouchDeserveButton(self)
        }
    }
    
    @IBAction func suxxsTouched(sender: AnyObject) {
        if !didVote {
            setSuxxsSelected()
            delegate?.postCellDidTouchSuxxsButton(self)
        }
    }
}
