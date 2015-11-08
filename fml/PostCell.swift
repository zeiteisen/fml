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

    @IBOutlet weak var suxxsFImageView: UIImageView!
    @IBOutlet weak var suxxsContainerView: UIView!
    @IBOutlet weak var suxxsLabelBackgroundView: UIView!
    @IBOutlet weak var suxxsCountVotesBackgroundView: UIView!
    @IBOutlet weak var suxxsCountVotesLabel: UILabel!
    @IBOutlet weak var suxxsLabel: UILabel!
    @IBOutlet weak var suxxsButton: UIButton!
    
    
    @IBOutlet weak var deserveItContainerView: UIView!
    @IBOutlet weak var deserveItLabelBackgroundView: UIView!
    @IBOutlet weak var deserveItLabel: UILabel!
    @IBOutlet weak var deserveItCountVotesBackgroundView: UIView!
    @IBOutlet weak var deserveItCountLabel: UILabel!
    @IBOutlet weak var deserveItButton: UIButton!
    
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
        if !NSProcessInfo.iOS9OrGreater() {
            messageLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 24
        }
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        suxxsContainerView.layer.masksToBounds = true
        suxxsCountVotesLabel.textColor = UIColor.backgroundColor()
        suxxsContainerView.backgroundColor = UIColor.clearColor()
        suxxsContainerView.layer.cornerRadius = 5
        suxxsLabel.text = "suxxs_button_title".localizedString
        
        deserveItContainerView.layer.masksToBounds = true
        deserveItCountLabel.textColor = UIColor.backgroundColor()
        deserveItContainerView.backgroundColor = UIColor.clearColor()
        deserveItContainerView.layer.cornerRadius = 5
        deserveItLabel.text = "deserve_button_title".localizedString
        
        
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
        createdAtLabel.text = dateformatter.stringFromDate(object.createdAt!)
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
        suxxsContainerView.userInteractionEnabled = true
        suxxsButton.selected = false
        suxxsCountVotesBackgroundView.backgroundColor = UIColor.textColor()
        suxxsFImageView.tintColor = UIColor.textColor()
        suxxsLabel.textColor = UIColor.textColor()
        suxxsContainerView.layer.borderColor = UIColor.textColor().CGColor
        suxxsContainerView.layer.borderWidth = 2
        suxxsLabelBackgroundView.backgroundColor = UIColor.backgroundColor()
        
        deserveItContainerView.userInteractionEnabled = true
        deserveItButton.selected = false
        deserveItCountVotesBackgroundView.backgroundColor = UIColor.textColor()
        deserveItLabel.textColor = UIColor.textColor()
        deserveItContainerView.layer.borderColor = UIColor.textColor().CGColor
        deserveItContainerView.layer.borderWidth = 2
        deserveItLabelBackgroundView.backgroundColor = UIColor.backgroundColor()
        deserveItContainerView.alpha = 1
        suxxsContainerView.alpha = 1
    }
    
    func setVoteButtonLabels(suxxsCount: Int, deservCount: Int) {
        suxxsCountVotesLabel.text = "\(suxxsCount)"
        deserveItCountLabel.text = "\(deservCount)"
    }
    
    func setSuxxsSelected() {
        didVote = true
        suxxsContainerView.userInteractionEnabled = false
        suxxsButton.selected = false
        suxxsCountVotesBackgroundView.backgroundColor = UIColor.accentColor()
        suxxsFImageView.tintColor = UIColor.backgroundColor()
        suxxsLabel.textColor = UIColor.backgroundColor()
        suxxsContainerView.layer.borderColor = UIColor.textColor().CGColor
        suxxsContainerView.layer.borderWidth = 0
        suxxsLabelBackgroundView.backgroundColor = UIColor.textColor()
        deserveItButton.userInteractionEnabled = false
        deserveItContainerView.alpha = 0.5
    }
    
    func setDeserveSelected() {
        didVote = true
        deserveItContainerView.userInteractionEnabled = false
        deserveItButton.selected = true
        deserveItCountVotesBackgroundView.backgroundColor = UIColor.accentColor()
        deserveItLabel.textColor = UIColor.backgroundColor()
        deserveItContainerView.layer.borderColor = UIColor.textColor().CGColor
        deserveItContainerView.layer.borderWidth = 0
        deserveItLabelBackgroundView.backgroundColor = UIColor.textColor()
        suxxsButton.userInteractionEnabled = false
        suxxsContainerView.alpha = 0.5
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
