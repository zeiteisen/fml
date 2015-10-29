//
//  PostCell.swift
//  fml
//
//  Created by Hanno Bruns on 18.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import UIKit

protocol PostCellDelegate {
    func postCellDidTouchSuxxsButton(sender: PostCell)
    func postCellDidTouchDeserveButton(sender: PostCell)
    func postCellDidTouchShare(sender: PostCell)
    func postCellDidTouchComments(sender: PostCell)
}

class PostCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var suxxsButton: UIButton!
    @IBOutlet weak var deserveItButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    var delegate: PostCellDelegate?
    var didVote = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if !NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)) {
            messageLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 24
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func resetState() {
        didVote = false
        suxxsButton.selected = false
        suxxsButton.userInteractionEnabled = true
        suxxsButton.alpha = 1.0
        deserveItButton.selected = false
        deserveItButton.alpha = 1.0
        deserveItButton.userInteractionEnabled = true
        suxxsButton.setTitle("suxxs_button_title".localizedString, forState: .Normal)
        deserveItButton.setTitle("deserve_button_title".localizedString, forState: .Normal)
    }
    
    func setVoteButtonLabels(suxxsCount: Int, deservCount: Int) {
        suxxsButton.setTitle("suxxs_button_title".localizedString + " \(suxxsCount)", forState: .Normal)
        deserveItButton.setTitle("deserve_button_title".localizedString + " \(deservCount)", forState: .Normal)
    }
    
    func setSuxxsSelected() {
        didVote = true
        suxxsButton.selected = true
        deserveItButton.alpha = 0.5
        suxxsButton.userInteractionEnabled = false
        deserveItButton.userInteractionEnabled = false
    }
    
    func setDeserveSelected() {
        didVote = true
        suxxsButton.alpha = 0.5
        deserveItButton.selected = true
        suxxsButton.userInteractionEnabled = false
        deserveItButton.userInteractionEnabled = false
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
