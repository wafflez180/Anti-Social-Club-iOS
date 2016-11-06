//
//  Constants.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/10/16.
//  Copyright © 2016 Cult of the Old Gods. All rights reserved.
//

import Foundation

class Constants
{
    class User
    {
        static let RANK_MEMBER = 0
        static let RANK_PIONEER = 1
        static let RANK_MODERATOR = 2
        static let RANK_ADMINISTRATOR = 3
    }

    class API
    {
        static let ADDRESS = "https://api.ub-anti-social.club/"
        static let IMAGE_DIRECTORY = "images/"
        static let CALL_CONFIRM_NAME = "ConfirmName.php"
        static let CALL_CONFIRM_KEY = "ConfirmKey.php"
        static let CALL_CONFIRM_EMAIL = "ConfirmEmail.php"
        static let CALL_LOGIN = "Login.php"
        static let CALL_RETRIEVE_POSTS = "RetrievePosts.php"
        static let CALL_RETRIEVE_POST = "RetrievePost.php"
        static let CALL_RETRIEVE_COMMENTS = "RetrieveComments.php"
        static let CALL_RETRIEVE_USER_INFO = "RetrieveUserInfo.php"
        static let CALL_RETRIEVE_USER_KEYS = "RetrieveUserKeys.php"
        static let CALL_POST = "Post.php"
        static let CALL_SEND_INVITE = "SendInvite.php"
        static let CALL_VOTE = "Vote.php"
        static let CALL_REPORT = "ReportPost.php"
        static let CALL_COMMENT = "Comment.php"
        static let CALL_REGISTER_FCM_TOKEN = "RegisterFCMToken.php"
        static let CALL_FOLLOW_POST = "FollowPost.php"
        static let CALL_UNFOLLOW_POST = "UnfollowPost.php"
        static let CALL_DEACTIVATE_USER = "DeactivateUser.php"
    }
    
    class Products
    {
        static let PRODUCT_ACCESS_KEY = "access_key"
    }
}
