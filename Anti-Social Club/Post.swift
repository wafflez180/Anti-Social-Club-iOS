//
//  Post.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/10/16.
//  Copyright © 2016 Cult of the Old Gods. All rights reserved.
//

import Foundation
import SwiftyJSON

class Post{
    var id : Int?
    var posterId : Int?
    var message : String?
    var imageSource : String?
    var timestamp : String?
    var voted : Bool?
    var votedBadge : Int?
    var reported : Bool?
    var reportCount : Int?
    var commentCount : Int?
    var badgeFunnyCount : Int?
    var badgeDumbCount : Int?
    var badgeLoveCount : Int?
    var badgeAgreeCount : Int?
    var badgeDisagreeCount : Int?
    var downloadedImage : UIImage?
    var revealedPost : Bool = false
    var isFollowing : Bool?
    var isPinned : Bool?
    
    init?(id : Int?,
          posterId : Int?,
          message : String?,
          imageSource : String?,
          timestamp : String?,
          voted : Bool?,
          votedBadge : Int?,
          reported : Bool?,
          reportCount : Int?,
          commentCount : Int?,
          badgeFunnyCount : Int?,
          badgeDumbCount : Int?,
          badgeLoveCount : Int?,
          badgeAgreeCount : Int?,
          badgeDisagreeCount : Int?,
          isFollowing : Bool?,
          isPinned : Bool?) {
    
        self.id = id
        self.posterId = posterId
        self.message = message
        self.imageSource = imageSource
        self.timestamp = timestamp
        self.voted = voted
        self.votedBadge = votedBadge
        self.reported = reported
        self.reportCount = reportCount
        self.commentCount = commentCount
        self.badgeFunnyCount = badgeFunnyCount
        self.badgeDumbCount = badgeDumbCount
        self.badgeLoveCount = badgeLoveCount
        self.badgeAgreeCount = badgeAgreeCount
        self.badgeDisagreeCount = badgeDisagreeCount
        self.isFollowing = isFollowing
        self.isPinned = isPinned
        
        //print("Created Post:\n\tMessage: \"\(message!)\"\n\tImageURL: \(imageSource)")
    }

    convenience init?(json : JSON)
    {
        let newId = json["id"].int
        let newPosterId = json["poster_id"].int
        let newMessage = json["message"].string
        let newImageSource = json["image_source"].string
        let newTimestamp = json["timestamp"].string
        let newVoted = json["voted"].bool
        let newVotedBadge = json["voted_badge"].int
        let newReported = json["reported"].bool
        let newReportCount = json["report_count"].int
        let newCommentCount = json["comment_count"].int
        let newFunnyBadgeCount = json["badge_funny_count"].int
        let newDumbBadgeCount = json["badge_dumb_count"].int
        let newLoveBadgeCount = json["badge_love_count"].int
        let newAgreeBadgeCount = json["badge_agree_count"].int
        let newDisagreeBadgeCount = json["badge_disagree_count"].int
        let isFollowing = json["followed"].bool
        let isPinned = Bool(json["is_pinned"].intValue)
        
        //print("\(json["is_pinned"])")
        
        self.init(id: newId, posterId: newPosterId, message: newMessage, imageSource: newImageSource, timestamp: newTimestamp, voted: newVoted, votedBadge: newVotedBadge, reported: newReported, reportCount: newReportCount, commentCount: newCommentCount, badgeFunnyCount: newFunnyBadgeCount, badgeDumbCount: newDumbBadgeCount, badgeLoveCount: newLoveBadgeCount, badgeAgreeCount: newAgreeBadgeCount, badgeDisagreeCount: newDisagreeBadgeCount, isFollowing: isFollowing, isPinned: isPinned)
    }
    
}

extension Bool {
    init<T : Integer>(_ integer: T){
        self.init(integer != 0)
    }
}
