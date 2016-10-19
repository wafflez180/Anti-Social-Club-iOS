//
//  HomePageTableViewController.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/10/16.
//  Copyright © 2016 Cult of the Old Gods. All rights reserved.
//

import UIKit

class HomepageTableViewController: UITableViewController
{
    var postsArray = [Post]()
    var userName : String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Debuging
        createTestPost()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //Crashlytics.sharedInstance().crash()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - HomepageTableViewController
    
    func createTestPost(){
        let testPost = Post(message: "Hey fam! It’s ya boi If anybody would like to come tonight at Davis Hall we are hosting an iOS workshop. We will be teaching swift! Invite your friends.", laughingBadgeCount: 2, notAmusedBadgeCount: 6, heartBadgeCount: 1, likeBadgeCount: 1, dislikeBadgeCount: 1, timestamp: "2h", imageUrl: nil)
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
    
    // MARK: - Table view data source

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
