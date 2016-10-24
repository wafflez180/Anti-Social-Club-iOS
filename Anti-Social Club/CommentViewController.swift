//
//  CommentTableViewController.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/23/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var postCell : PostTableViewCell?
    var commentArray : [Comment] = []

    @IBOutlet weak var commentTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTableview.delegate = self
        commentTableview.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.=
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let defaults = UserDefaults.standard
        let offsetBullshitIncrement = 20
        attemptRetrieveComments(offset: (postCell?.parentVC.postsArray.count)!-offsetBullshitIncrement, token: defaults.string(forKey: "token")!, postId: (postCell?.post?.id)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func attemptRetrieveComments(offset: Int, token: String, postId: Int)
    {
        print("Attempting to retrieve comments with\n\tOffset: \(offset)\n\tToken: \(token)\n\tPost_ID: \(postId)")
        
        let parameters = ["offset" : offset, "token" : token, "post_id" : postId] as [String : Any]
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityView.center=self.view.center;
        activityView.frame = self.view.frame
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_RETRIEVE_COMMENTS, method: .post, parameters: parameters)
            .responseJSON()
                {
                    response in
                    
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    
                    switch response.result
                    {
                    case .success(let responseData):
                        let json = JSON(responseData)
                        
                        // Handle any errors
                        if json["error"].bool == true
                        {
                            print("ERROR: \(json["error_message"].stringValue)")
                            let alert = UIAlertController(title: "Error", message: "Network Error! Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            
                            return
                        }
                        
                        let jsonArray = json["comments"].array
                        for subJSON in jsonArray!
                        {
                            if let comment : Comment = Comment(json: subJSON)
                            {
                                self.commentArray+=[comment]
                            }
                        }
                        
                        self.commentTableview.reloadData()
                        
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        let alert = UIAlertController(title: "Error", message: "Network Error! Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        return
                    }
        }
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView;
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1 + commentArray.count
    }

    //For automatic resizing with different textlabel heights
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 375
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
            cell.configureCellWithPost(post: (postCell?.post!)!, section: indexPath.row)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
            cell.configureWithComment(comment: commentArray[indexPath.row-1])
            return cell
        }
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
