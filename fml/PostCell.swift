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
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    var delegate: PostCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Actions
    
    @IBAction func didTouchShare(sender: AnyObject) {
        delegate?.postCellDidTouchShare(self)
    }
    
    @IBAction func commentsTouched(sender: AnyObject) {
        delegate?.postCellDidTouchComments(self)
    }
    
    @IBAction func deserveTouched(sender: AnyObject) {
        delegate?.postCellDidTouchDeserveButton(self)
    }
    
    @IBAction func suxxsTouched(sender: AnyObject) {
    delegate?.postCellDidTouchSuxxsButton(self)
    }
}
