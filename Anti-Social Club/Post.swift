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
    var message : String?
    var timestamp : String?
    var laughingBadgeCount : Int?
    var notAmusedBadgeCount : Int?
    var heartBadgeCount : Int?
    var likeBadgeCount : Int?
    var dislikeBadgeCount : Int?
    var imageUrl : String?
    
    init?(message : String?, laughingBadgeCount : Int?, notAmusedBadgeCount : Int?, heartBadgeCount : Int?, likeBadgeCount : Int?, dislikeBadgeCount : Int?, timestamp: String?, imageUrl: String?)
    {
        // CODE REVIEW:
        // What happens if I pass in a negative badge count? Could cause bad news down the line.
        // Insert some checks here to make sure that the counts are >= 0, and return nil if they aren't.
        // This will return nil if we get an invalidly deserialized post, and then we can handle it.
    
        self.message = message
        self.timestamp = timestamp
        self.laughingBadgeCount = laughingBadgeCount
        self.notAmusedBadgeCount = notAmusedBadgeCount
        self.heartBadgeCount = heartBadgeCount
        self.likeBadgeCount = likeBadgeCount
        self.dislikeBadgeCount = dislikeBadgeCount
        self.imageUrl = imageUrl
        
        print("Created Post:\n\tMessage: \"\(message!)\"\n\tImageURL: \(imageUrl)")
    }
    /*
    convenience init?(json : JSON)
    {
        //TODO
        let newMessage = json["message"].string
        let newName = json["name"].string
        let newBrand = json["brand"].string
        let newPrice = json["price"].float
        let newImageUrl = json["image_url"].string
        //let newImageUrl = "http://i.imgur.com/VamlAl4.png"
        
        self.init(message : String?, laughingBadgeCount : int?, notAmusedBadgeCount : int?, heartBadgeCount : int?, likeBadgeCount : int?, dislikeBadgeCount : int?, imageUrl: String?)
    }*/
}
