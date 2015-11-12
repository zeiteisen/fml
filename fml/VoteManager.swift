//
//  VoteManager.swift
//  fml
//
//  Created by Hanno Bruns on 12.11.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
//

import Foundation
import Parse

class VoteManager {
    
    static let sharedInstance = VoteManager()
    
    init() {
        updateVotesArray()
    }
    
    var votes = [String : String]()
    
    func saveVote(kind: String, post: PFObject, completion: (() -> ())?) {
        if let postObjectId = post.objectId {
            votes[postObjectId] = kind
        }
        if kind == Constants.upvote {
            post.incrementKey(Constants.countUpvotes)
        } else {
            post.incrementKey(Constants.countDownvotes)
        }
        post.saveEventually()
        let voteObject = PFObject(className: "Vote")
        voteObject["owner"] = PFUser.currentUser()
        voteObject["post"] = post
        voteObject["kind"] = kind
        voteObject.pinInBackgroundWithName("Votes", block: { (success: Bool, error: NSError?) -> Void in
            if success {
                completion?()
            }
        })
        voteObject.saveEventually()
    }
    
    func updateVotesArray() {
        // TODO remote download the votes from the user. Use Case: App reinstall, Local Datastore may get deleted. Worst case scenario: User can vote multiple times. Minor case... fml saves votes locally with coockies.
        let query = PFQuery(className: "Vote")
        query.whereKeyExists("post")
        query.whereKeyDoesNotExist("comment")
        query.fromLocalDatastore()
        query.limit = 1000 // TODO add support for more than 1000 votes
        query.findObjectsInBackgroundWithBlock { (votes: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("searching local vote failed: \(error)")
            } else if let votes = votes {
                self.votes.removeAll()
                for vote in votes {
                    let votePost = vote["post"] as! PFObject
                    self.votes[votePost.objectId!] = vote["kind"] as? String
                }
            }
        }
    }
    
}