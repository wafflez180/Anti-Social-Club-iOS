//
//  PostTableViewCell.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/10/16.
//  Copyright © 2016 Cult of the Old Gods. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PostTableViewCell: UITableViewCell {

    
    @IBOutlet weak var laughingBadgeButton: UIButton!
    @IBOutlet weak var notAmusedBadgeButton: UIButton!
    @IBOutlet weak var heartBadgeButton: UIButton!
    @IBOutlet weak var likeBadgeButton: UIButton!
    @IBOutlet weak var dislikeBadgeButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var imageViewHeightContraint: NSLayoutConstraint!
    
    var userVoted : Bool?
    var userVotedBadge : Int?
    var userReported : Bool?
    var loadedContent : Bool = false
    var post : Post?
    var parentVC : HomepageTableViewController!
    var section : Int?
    var commentViewCont : CommentViewController?

    func configureCellWithPost(post: Post, section: Int) {
        loadedContent = true
        messageLabel.text = post.message
        userReported = post.reported
        userVoted = post.voted
        userVotedBadge = post.votedBadge
        self.post = post
        self.section = section
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.hexStringToUIColor(hex: "BDBDBD").cgColor
        
        let tempDateFormatter = DateFormatter()
        tempDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        tempDateFormatter.timeZone = TimeZone(identifier: "GMT")
        tempDateFormatter.locale = Locale(identifier: "en_US")
        
        //Set Labels
        let creationDate = tempDateFormatter.date(from: post.timestamp!)
        setTimestamp(withDateCreated: creationDate!)
        
        laughingBadgeButton.setTitle(String(describing: post.badgeFunnyCount!), for: UIControlState.normal)
        notAmusedBadgeButton.setTitle(String(describing: post.badgeDumbCount!), for: UIControlState.normal)
        heartBadgeButton.setTitle(String(describing: post.badgeLoveCount!), for: UIControlState.normal)
        likeBadgeButton.setTitle(String(describing: post.badgeAgreeCount!), for: UIControlState.normal)
        dislikeBadgeButton.setTitle(String(describing: post.badgeDisagreeCount!), for: UIControlState.normal)
        commentButton.setTitle(String(describing: post.commentCount!), for: UIControlState.normal)
        reportButton.setTitle(String(describing: post.reportCount!), for: UIControlState.normal)
        
        if userReported!{
            reportButton.isSelected = true
        }
        
        if userVoted! {
            // TODO get the votedBagde ID and perfrom the animation
        }
        //print(post.imageSource)
        //print(post.message)
        if ((post.imageSource == nil) || (post.imageSource?.characters.count)! == 0) {
            self.postImageView.isHidden = true
            self.imageViewHeightContraint.constant = 0
            self.layoutIfNeeded()
            self.setNeedsLayout()
        }
        else{
            self.postImageView.isHidden = false
            self.imageViewHeightContraint.constant = 200
            self.layoutIfNeeded()
            self.setNeedsLayout()
            // TODO:
            // Download the image. This should be done with AlamofireImage library, as it handles
            // proper caching and is very performant.
        }
    }
    
    func setTimestamp(withDateCreated : Date){
        let currentDate = Date()
        
        self.timestampLabel.numberOfLines=0
        if(currentDate.months(from: withDateCreated) > 0){
            self.timestampLabel.text = "\(currentDate.months(from: withDateCreated))mts"
        }else if(currentDate.weeks(from: withDateCreated) > 0){
            self.timestampLabel.text = "\(currentDate.weeks(from: withDateCreated))w"
        }else if(currentDate.days(from: withDateCreated) > 0){
            self.timestampLabel.text = "\(currentDate.days(from: withDateCreated))d"
        }else if(currentDate.hours(from: withDateCreated) > 0){
            self.timestampLabel.text = "\(currentDate.hours(from: withDateCreated))h"
        }else if(currentDate.minutes(from: withDateCreated) > 0){
            self.timestampLabel.text = "\(currentDate.minutes(from: withDateCreated))m"
        }else if(currentDate.seconds(from: withDateCreated) > 0){
            self.timestampLabel.text = "\(currentDate.seconds(from: withDateCreated))s"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func attemptReportPost(token: String, postId: Int)
    {
        let parameters = ["token" : token, "post_id" : postId] as [String : Any]
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_REPORT, method: .post, parameters: parameters)
            .responseJSON()
                {
                    response in
                    
                    switch response.result
                    {
                    case .success(let responseData):
                        //let json = JSON(responseData)
                        self.reportButton.isSelected = true
                        self.reportButton.setTitle(String(describing: (self.post?.reportCount!)!+1), for: UIControlState.selected)
                        
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        
                        return
                    }
        }
    }
    
    // MARK: - IBActions

    @IBAction func viewComments(_ sender: UIButton) {
        //If the comment button was pressed inside the comment view
        if self.commentViewCont != nil {
            self.commentViewCont?.composeCommentTextField.becomeFirstResponder()
        }else{
            parentVC.selectedPostCell = self
            parentVC.performSegue(withIdentifier: "commentSegue", sender: nil)
        }
    }
    
    @IBAction func report(_ sender: UIButton)
    {
        if self.post?.reported == false && self.reportButton.isSelected == false {
            let deactivateAlert = UIAlertController(title: "Report Post", message: "Are you sure you want to report this post?", preferredStyle: UIAlertControllerStyle.alert)
            
            deactivateAlert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (action: UIAlertAction!) in
                print("User Reported Post")
                let defaults = UserDefaults.standard
                let token = defaults.string(forKey: "token")
                self.attemptReportPost(token: token!, postId: (self.post?.id)!)
            }))
            deactivateAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            
            self.parentVC.present(deactivateAlert, animated: true, completion: nil)
        }
    }
    @IBAction func selectedLaughingBadge(_ sender: UIButton)
    {
        
    }
    @IBAction func selectedNotAmusedBadge(_ sender: UIButton)
    {
        
    }
    @IBAction func selectedHeartBadge(_ sender: UIButton)
    {
        
    }
    @IBAction func selectedLikeBadge(_ sender: UIButton)
    {
        
    }
    @IBAction func selectedDislikeBadge(_ sender: UIButton)
    {
        
    }
    
}
