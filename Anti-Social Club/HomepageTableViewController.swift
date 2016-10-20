//
//  HomePageTableViewController.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/10/16.
//  Copyright © 2016 Cult of the Old Gods. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HomepageTableViewController: UITableViewController {
    var postsArray = [Post]()
    var userName : String?
    var userToken : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Debuging
        //createTestPost()
        
        let navController = self.navigationController as! CustomNavigationController
        userName = navController.username
        userToken = navController.userToken
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //Crashlytics.sharedInstance().crash()
        
        retrievePosts(offset: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - HomepageTableViewController
    
    func retrievePosts(offset: Int) {
        print("Attempting to retrieve posts for user \(userName!) with token \(userToken!)")
        
        let parameters : Parameters = ["token": userToken!, "offset": offset]
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_RETRIEVE_POSTS, method: .post, parameters: parameters)
        .responseJSON()
        {
            response in
            
            //debugPrint(response)
            
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
                                //print("Got post \(newPost.id!)")
                                self.postsArray += [newPost]
                            }
                        }
                    
                    }
                    
                    self.tableView.reloadData()
                    
                    return
                
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    return
            }
        }

    }
    
    func createTestPost(){
        //let testPost = Post(message: "Hey fam! It’s ya boi If anybody would like to come tonight at Davis Hall we are hosting an iOS workshop. We will be teaching swift! Invite your friends.", laughingBadgeCount: 2, notAmusedBadgeCount: 6, heartBadgeCount: 1, likeBadgeCount: 1, dislikeBadgeCount: 1, timestamp: "2h", imageUrl: nil)
        let testMessage = "Hey fam! It’s ya boi If anybody would like to come tonight at Davis Hall we are hosting an iOS workshop. We will be teaching swift! Invite your friends."
        let testPost = Post(id: 0, posterId: 0, message: testMessage, imageSource: "", timestamp: "", voted: false, votedBadge: nil, reported: false, reportCount: 5, commentCount: 3, badgeFunnyCount: 7, badgeDumbCount: 6, badgeLoveCount: 4, badgeAgreeCount: 2, badgeDisagreeCount: 1)
        postsArray+=[testPost!]
        tableView.reloadData()
    }
    
    func setupComposePostPopupWithBlur() -> ComposePostView{
        
        let composePostView = Bundle.main.loadNibNamed("ComposePost", owner: self, options: nil)?[0] as! ComposePostView
        
        composePostView.parentVC = self
        composePostView.viewDidLoad()
        self.view.addSubview(composePostView)
        
        return composePostView
    }
    
    // MARK: - ToolBar Actions
    
    @IBAction func pressedCreatePost(_ sender: UIBarButtonItem) {
        let composePostView = setupComposePostPopupWithBlur()
        composePostView.presentPopup()
    }
    
    // MARK: - TableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return postsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        
        cell.configureCellWithPost(post: postsArray[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // CODE REVIEW:
        // This is a "magic number". You should change it to a const variable and then define that variable
        // a the top of the class.
        tableView.tableHeaderView?.backgroundColor = UIColor.clear
    
        return 10
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
