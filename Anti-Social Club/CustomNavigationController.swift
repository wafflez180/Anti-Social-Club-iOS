//
//  CustomNavigationController.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/18/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit
import Whisper
import Alamofire
import SwiftyJSON

class CustomNavigationController: UINavigationController {
    
    var username : String?
    var userToken : String?
    var tempNotifcationPostId : Int?
    var tempNotificationPost : Post?
    var checkNotification : Bool?
    var notificationType : String?
    var rankId : Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedLocalNotification),
            name: NSNotification.Name(rawValue: "localNotification"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedRemoteNotification),
            name: NSNotification.Name(rawValue: "remoteNotification"),
            object: nil)
        retrieveUserInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveUserInfo()
    {
        let token = UserDefaults.standard.string(forKey: "token")!
        let parameters = ["token" : token]
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_RETRIEVE_USER_INFO, method: .post, parameters: parameters)
            .responseJSON()
                {
                    response in
                    
                    switch response.result
                    {
                    case .success(let responseData):
                        let json = JSON(responseData)
                        
                        // Handle any errors
                        if json["error"].bool == true
                        {
                            print("ERROR: \(json["error_message"].stringValue)")
                            return
                        }
                        
                        // Parse returned user info
                        if (json["user_info"].dictionary != nil)
                        {
                            let userInfoJSON = json["user_info"].dictionary!
                            
                            self.rankId = userInfoJSON["rank"]!.intValue
                            
                            print("Got user info! Rank id is \(self.rankId)")
                            
                            return
                        }
                        
                        print("Test")
                        
                    case .failure(let error):
                        (self.navigationController as! CustomNavigationController).networkError()
                        print("Request failed with error: \(error)")
                        return
                    }
        }
    }
    
    func receivedLocalNotification(notification: NSNotification){
        print("Received Notification Locally")
        let messageBody = notification.userInfo?["body"] as! String
        let postId = notification.userInfo?["post_id"] as! Int
        notificationType = notification.userInfo?["notification_type"] as? String
        
        tempNotifcationPostId = postId
        
        let announcement = Announcement(title: "Notification", subtitle: messageBody, image: nil, duration: 5, action:{
            print("Pressed the shniz")
            self.attemptRetrievePost(postId: postId)
        })
    
        print("Showing Local Notification")

        
        Whisper.show(shout: announcement, to: self, completion: {
            print("Finished Showing Local Notification")
        })
    }
    
    func receivedRemoteNotification(notification: NSNotification){
        print("Received Notification Remotely")
        let postId = notification.userInfo?["post_id"] as! Int
        notificationType = notification.userInfo?["notification_type"] as? String
        
        tempNotifcationPostId = postId
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.notificationData = nil
        
        self.attemptRetrievePost(postId: postId)
    }
    
    func attemptRetrievePost(postId: Int) {
        print("Attempting to retrieve post from notification")
        
        let parameters : Parameters = ["token": self.userToken!, "offset": 0, "post_id": postId]
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityView.center = (self.visibleViewController?.view.center)!
        activityView.frame = (self.visibleViewController?.view.frame)!
        activityView.startAnimating()
        self.visibleViewController?.view.addSubview(activityView)
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_RETRIEVE_POSTS, method: .post, parameters: parameters)
            .responseJSON()
                {
                    response in
                    
                    switch response.result
                    {
                    case .success(let responseData):
                        let json = JSON(responseData)
                        
                        // Handle any errors
                        if json["error"].bool == true
                        {
                            print("ERROR: \(json["error_message"].stringValue)")
                            
                            return
                        }
                        
                        if let postsJSONArray = json["posts"].array
                        {
                            for postJSON in postsJSONArray
                            {
                                if let newPost : Post = Post(json: postJSON)
                                {
                                    //Should be only 1 element
                                    
                                    activityView.stopAnimating()
                                    activityView.removeFromSuperview()
                                    
                                    self.tempNotificationPost = newPost
                                    
                                    self.performSegue(withIdentifier: "showPostSegue", sender: nil)
                                }
                            }
                        }
                        
                        return
                        
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        
                        return
                    }
        }
        
    }
    
    func networkError(){
        performSegue(withIdentifier: "networkErrorSegue", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "showPostSegue")
        {
            let destination = segue.destination as! CommentViewController
            destination.postId = tempNotifcationPostId
            destination.notificationPost = tempNotificationPost
            destination.fromNotification = true
            destination.scrollToNotificationComment = (notificationType == "comment")
        }
    }
    

}
