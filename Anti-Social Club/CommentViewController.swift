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
import Crashlytics

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var parentVC : HomepageTableViewController?
    var postCell : PostTableViewCell?
    var commentArray : [Comment] = []
    var tapGestureRec : UITapGestureRecognizer?
    var postId : Int?
    var retrievingComments: Bool = false

    @IBOutlet weak var commentTableview: UITableView!
    @IBOutlet weak var composeCommentViewBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var composeCommentView: UIView!
    @IBOutlet weak var composeCommentTextField: UITextField!
    @IBOutlet weak var sendCommentButton: UIButton!
    
    var postedNewComment : Bool = false
    var showingFullScreenImage : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTableview.delegate = self
        commentTableview.dataSource = self
        composeCommentTextField.delegate = self
        
        composeCommentView.layer.borderWidth = 1
        composeCommentView.layer.borderColor = UIColor.hexStringToUIColor(hex: "C7C7CD").cgColor
        
        addNotifications()

        let defaults = UserDefaults.standard
        postId = (postCell?.post?.id)!
        attemptRetrieveComments(offset: 0, token: defaults.string(forKey: "token")!, postId: postId!)
        
        self.commentTableview.refreshControl = UIRefreshControl()
        self.commentTableview.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showingFullScreenImage = false
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if showingFullScreenImage == false {
            postCell?.commentViewCont = nil
        }
        self.navigationController?.setToolbarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender:AnyObject)
    {
        let defaults = UserDefaults.standard
        self.commentArray.removeAll()
        attemptRetrieveComments(offset: 0, token: defaults.string(forKey: "token")!, postId: postId!)
    }
    
    func attemptRetrieveComments(offset: Int, token: String, postId: Int)
    {
        retrievingComments = true
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
                        
                        var reachedLoadedPostsLimit = false

                        let jsonArray = json["comments"].array
                        for subJSON in jsonArray!
                        {
                            if let comment : Comment = Comment(json: subJSON)
                            {
                                self.commentArray+=[comment]
                            }
                        }
                        reachedLoadedPostsLimit = jsonArray?.count == 0
                        
                        if !reachedLoadedPostsLimit {
                            DispatchQueue.main.async{
                                self.commentTableview.reloadData()
                                self.commentTableview.refreshControl?.endRefreshing()
                            }
                        }
                        
                        if self.postedNewComment {
                            let lastRowIndexPath = IndexPath(row: self.commentArray.count, section: 0)
                            DispatchQueue.main.async{
                                self.commentTableview.scrollToRow(at: lastRowIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
                            }
                            self.postedNewComment = false
                            
                            self.postCell?.post?.commentCount = (self.postCell?.post?.commentCount)!+1
                            self.postCell?.commentButton.setTitle(String(describing: (self.postCell?.post?.commentCount!)), for: UIControlState.normal)
                            self.parentVC?.selectedPostCell?.commentButton.setTitle(String(describing: (self.postCell?.post?.commentCount!)!), for: UIControlState.normal)
                            self.commentTableview.layoutIfNeeded()
                        }
                        
                        self.retrievingComments = false
                        
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        let alert = UIAlertController(title: "Error", message: "Network Error! Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        return
                    }
        }
    }
    
    func attemptPostComment(token: String, message: String, postId: Int)
    {
        print("Attempting to post comment with\n\tMessage: \(message)\n\tToken: \(token)\n\tPost_ID: \(postId)")
        
        let parameters = ["token" : token, "message" : message, "post_id" : postId] as [String : Any]
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityView.center=self.sendCommentButton.center;
        activityView.frame = self.sendCommentButton.frame
        activityView.startAnimating()
        self.composeCommentView.addSubview(activityView)
        dismissKeyboard()
        composeCommentTextField.isEnabled = false
        sendCommentButton.isHidden = true
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_COMMENT, method: .post, parameters: parameters)
            .responseJSON()
                {
                    response in
                    
                    print(response)
                    
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    
                    self.sendCommentButton.isHidden = false
                    self.composeCommentTextField.isEnabled = true
                    
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
                        }else if json["silenced"].bool == true{
                            let alert = UIAlertController(title: "Silenced", message: "You are silenced, and are not allowed to post or comment.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }else{
                            self.composeCommentTextField.text = ""
                            self.postedNewComment = true
                            self.attemptRetrieveComments(offset: self.commentArray.count, token: token, postId: postId)
                            Answers.logCustomEvent(withName: "Comment", customAttributes: [:])
                        }
                        
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
            cell.commentViewCont = self
            cell.configureCellWithPost(post: (postCell?.post!)!, section: indexPath.row)
            postCell = cell
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
            if (commentArray.count > 0){
                cell.postCell = postCell
                cell.configureWithComment(comment: commentArray[indexPath.row-1])
            }
            if indexPath.row > commentArray.count-2{
                let defaults = UserDefaults.standard
                print(self.commentArray.count)
                if retrievingComments == false {
                    attemptRetrieveComments(offset: self.commentArray.count, token: defaults.string(forKey: "token")!, postId: self.postId!)
                }
            }
            return cell
        }
    }
    
    
    // MARK: - Keyboard
    
    func addNotifications(){
        // Listen for keyboard appearances and disappearances
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
    }
    
    
    func handleKeyboardWillHide(sender: NSNotification){
        UIView.animate(withDuration: 0.2) {
            self.composeCommentViewBotConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        
        self.commentTableview.removeGestureRecognizer(tapGestureRec!)
    }
    
    func handleKeyboardWillShow(sender: NSNotification){
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        UIView.animate(withDuration: 0.2) {
            self.composeCommentViewBotConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
        
        tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.commentTableview.addGestureRecognizer(tapGestureRec!)
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    // MARK: - TextField
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dismissKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
    // MARk: - Actions
    
    @IBAction func pressedSendComment(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
       // self.attemptRetrieveComments(offset: self.commentArray.count, token: defaults.string(forKey: "token")!, postId: (self.postCell?.post?.id)!)

        attemptPostComment(token: defaults.string(forKey: "token")!, message: composeCommentTextField.text!, postId: postId!)
    }

    /*    CGSize keyboardSize = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

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
        if (segue.identifier == "viewFullImageSegue")
        {
            showingFullScreenImage = true
            let destination = segue.destination as! ViewImageViewController
            destination.fullSizeImage = self.postCell?.post?.downloadedImage
        }
    }
}
