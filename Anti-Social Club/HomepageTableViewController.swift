//
//  HomePageTableViewController.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/10/16.
//  Copyright © 2016 Cult of the Old Gods. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import Crashlytics

class HomepageTableViewController: UITableViewController {
    var postsArray = [Post]()
    var userName : String?
    var userToken : String?
    var selectedPostCell : PostTableViewCell?
    var selectedImage : UIImage?
    var composePostPopup : ComposePostView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Debuging
        //createTestPost()
        let navController = self.navigationController as! CustomNavigationController
        userName = navController.username
        userToken = navController.userToken

        //Crashlytics.sharedInstance().crash()
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)

        retrievePosts(offset: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - HomepageTableViewController
    
    func refresh(){
        self.postsArray.removeAll()
        retrievePosts(offset: 0)
    }
    
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
                    
                    var reachedLoadedPostsLimit = false
                    
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
                        reachedLoadedPostsLimit = postsJSONArray.count == 0
                    }
                    
                    
                    if !reachedLoadedPostsLimit {
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
                        }
                    }
                    
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
        composePostPopup = composePostView
        composePostView.parentVC = self
        composePostView.viewDidLoad()
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.view.addSubview(composePostView)
        
        return composePostView
    }
    
    // MARK: - ToolBar Actions
    
    @IBAction func pressedCreatePost(_ sender: UIBarButtonItem) {
        if (composePostPopup == nil) {
            let composePostView = setupComposePostPopupWithBlur()
            composePostView.presentPopup()
        }
    }
    
    // MARK: - TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return postsArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //For automatic resizing with different textlabel heights
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 375
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostTableViewCell
            if postsArray.count > 0 {
                cell.configureCellWithPost(post: postsArray[indexPath.section], section: indexPath.section)
                cell.parentVC = self
                //cell.timestampLabel.text = String(indexPath.section)
                
                if indexPath.section > postsArray.count-3{
                    retrievePosts(offset: self.postsArray.count)
                }
            }
            
            return cell
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "commentSegue")
        {
            let destination = segue.destination as! CommentViewController
            destination.postCell = selectedPostCell
            destination.parentVC = self
        } else if (segue.identifier == "viewFullImageSegue")
        {
            let destination = segue.destination as! ViewImageViewController
            destination.fullSizeImage = selectedImage!
        }else if (segue.identifier == "settingsSegue"){
            Answers.logContentView(
                withName: "Info View",
                contentType: "View",
                contentId: "Info",
                customAttributes: [:])
        }
        
    }
}
