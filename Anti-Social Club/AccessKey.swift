//
//  AccessKey.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/18/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import Foundation
import SwiftyJSON

//int id, String access_key, String rank, int owner_id, int redeemed

class AccessKey{
    var id : Int?
    var accessKey : String?
    var rank : String?
    var ownerId : Int?
    var isRedeemed : Bool?
    
    init?(id : Int?, access_key : String?, rank : String?, owner_id : Int?, redeemed : Bool?)
    {
        self.id = id
        self.accessKey = access_key
        self.rank = rank
        self.ownerId = owner_id
        self.isRedeemed = redeemed
        
        print("Retrieved AccessKey:\n\tKey: \(access_key!)\n\tRedeemed: \(redeemed!)")
    }
    
    convenience init?(json : JSON)
    {
        let newAccessKey = json["access_key"].string
        let newID = json["id"].int
        let newRank = json["rank"].string
        let newOwnerId = json["owner_id"].int
        let newRedeemed = json["redeemed"].int
        
        let redeemedBool : Bool!
        if newRedeemed == 0 {
            redeemedBool = false
        }else{
            redeemedBool = true
        }
        
        self.init(id : newID, access_key : newAccessKey, rank : newRank, owner_id : newOwnerId, redeemed : redeemedBool)
    }
}
