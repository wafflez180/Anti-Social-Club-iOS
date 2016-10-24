//
//  Comment.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/23/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import Foundation
import SwiftyJSON

class Comment{
    var id : Int?
    var postId : Int?
    var posterId : Int?
    var message : String?
    var timestamp : String?
    var color : String?
    
    init?( id : Int,
           postId : Int,
           posterId : Int,
           message : String,
           timestamp : String,
           color : String) {
        
        self.id = id
        self.postId = postId
        self.posterId = posterId
        self.message = message
        self.timestamp = timestamp
        self.color = color
    }
    
    convenience init?(json : JSON)
    {
        let newId = json["id"].int
        let newPostId = json["post_id"].int
        let newPosterId = json["poster_id"].int
        let newMessage = json["message"].string
        let newTimestamp = json["timestamp"].string
        let newColor = json["color"].string
        
        self.init(id : newId!, postId : newPostId!, posterId : newPosterId!, message : newMessage!, timestamp : newTimestamp!, color : newColor!)
    }
}
