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
    @IBOutlet weak var laughingLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var notAmusedLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var heartLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var dislikeLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightContraint: NSLayoutConstraint!
    
    var userVoted : Bool?
    var userVotedBadge : Int?
    var userReported : Bool?
    var loadedContent : Bool = false
    var post : Post?
    var parentVC : HomepageTableViewController!
    var section : Int?
    var commentViewCont : CommentViewController?
    var voteButtonArray : [UIButton] = []

    func configureCellWithPost(post: Post, section: Int) {
        loadedContent = true
        messageLabel.text = post.message
        userReported = post.reported
        userVoted = post.voted
        userVotedBadge = post.votedBadge
        self.post = post
        self.section = section
        
        voteButtonArray = [laughingBadgeButton,notAmusedBadgeButton,heartBadgeButton,likeBadgeButton,dislikeBadgeButton]
        
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
        }else{
            reportButton.isSelected = false
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
            let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentFullImageView))
            self.postImageView.addGestureRecognizer(tap)
            self.layoutIfNeeded()
            self.setNeedsLayout()
            // TODO:
            // Download the image. This should be done with AlamofireImage library, as it handles
            // proper caching and is very performant.
        }
        if userVoted! {
            resetBadges()
            selectBadge(badgeId: post.votedBadge!, animate: false)
        }else{
            resetBadges()
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
    
    func presentFullImageView(){
        parentVC.selectedImageView = self.postImageView
        parentVC.performSegue(withIdentifier: "viewFullImageSegue", sender: nil)
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
    
    func attemptVote(token: String, postId: Int, badgeId: Int)
    {
        let parameters = ["token" : token, "post_id" : postId, "badge_id" : badgeId] as [String : Any]
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_VOTE, method: .post, parameters: parameters)
            .responseJSON()
                {
                    response in
                    
                    switch response.result
                    {
                    case .success(let responseData):
                        //let json = JSON(responseData)
                        
                        //Increment the button title
                        switch badgeId {
                        case 0 :
                            self.laughingBadgeButton.setTitle(String(describing: (self.post?.badgeFunnyCount!)!+1), for: UIControlState.normal)
                        case 1:
                            self.notAmusedBadgeButton.setTitle(String(describing: (self.post?.badgeDumbCount!)!+1), for: UIControlState.normal)
                        case 2:
                            self.heartBadgeButton.setTitle(String(describing: (self.post?.badgeLoveCount!)!+1), for: UIControlState.normal)
                        case 3:
                            self.likeBadgeButton.setTitle(String(describing: (self.post?.badgeAgreeCount!)!+1), for: UIControlState.normal)
                        case 4:
                            self.dislikeBadgeButton.setTitle(String(describing: (self.post?.badgeDisagreeCount!)!+1), for: UIControlState.normal)
                        default :
                            print("Error")
                        }
                        
                        self.selectBadge(badgeId: badgeId, animate: true)
                        
                        self.post?.voted = true
                        self.userVoted = true
                        self.post?.votedBadge = badgeId
                        self.userVotedBadge = badgeId
                        
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        
                        return
                    }
        }
    }
    
    func selectBadge(badgeId: Int, animate: Bool){
        if badgeId == 0 {
            self.laughingBadgeButton.isSelected = true
            self.laughingBadgeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        }else if badgeId == 1 {
            self.notAmusedBadgeButton.isSelected = true
            self.notAmusedBadgeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        }else if badgeId == 2 {
            self.heartBadgeButton.isSelected = true
            self.heartBadgeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        }else if badgeId == 3 {
            self.likeBadgeButton.isSelected = true
            self.likeBadgeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        }else if badgeId == 4 {
            self.dislikeBadgeButton.isSelected = true
            self.dislikeBadgeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        }
        let leftPadding = 5
        let horizontalPadding = 40
        
        var buttonsToMove : [UIButton] = []
        var buttonsToDisappear : [UIButton] = []
        
        for button in voteButtonArray{
            if Int((button.titleLabel?.text)!)! == 0 && button.isSelected == false {
                buttonsToDisappear+=[button]
            }else{
                buttonsToMove+=[button]
            }
        }
        var animationTime = 0.5
        if animate == false{
            animationTime = 0.0
        }
        UIView.animate(withDuration: animationTime, animations: {
            for button in buttonsToDisappear{
                button.alpha = 0.0
            }
            for (index, button) in buttonsToMove.enumerated(){
                //Get the corresponding left constraint
                if button == self.laughingBadgeButton {
                    self.laughingLeftConstraint.constant = CGFloat((index * horizontalPadding) + leftPadding)
                }else if button == self.notAmusedBadgeButton{
                    self.notAmusedLeftConstraint.constant = CGFloat((index * horizontalPadding) + leftPadding)
                }else if button == self.heartBadgeButton{
                    self.heartLeftConstraint.constant = CGFloat((index * horizontalPadding) + leftPadding)
                }else if button == self.likeBadgeButton{
                    self.likeLeftConstraint.constant = CGFloat((index * horizontalPadding) + leftPadding)
                }else if button == self.dislikeBadgeButton{
                    self.dislikeLeftConstraint.constant = CGFloat((index * horizontalPadding) + leftPadding)
                }
                if button.isSelected == false{
                    button.alpha = 0.5
                }
            }
            self.layoutIfNeeded()
        })
    }
    
    func resetBadges(){
        self.laughingBadgeButton.isSelected = false
        self.notAmusedBadgeButton.isSelected = false
        self.heartBadgeButton.isSelected = false
        self.dislikeBadgeButton.isSelected = false
        self.likeBadgeButton.isSelected = false
        
        self.laughingBadgeButton.alpha = 1.0
        self.notAmusedBadgeButton.alpha = 1.0
        self.heartBadgeButton.alpha = 1.0
        self.dislikeBadgeButton.alpha = 1.0
        self.likeBadgeButton.alpha = 1.0
        
        let leftPadding = 5
        let horizontalPadding = 40
        
        self.laughingLeftConstraint.constant = CGFloat((0 * horizontalPadding) + leftPadding)
        self.notAmusedLeftConstraint.constant = CGFloat((1 * horizontalPadding) + leftPadding)
        self.heartLeftConstraint.constant = CGFloat((2 * horizontalPadding) + leftPadding)
        self.likeLeftConstraint.constant = CGFloat((3 * horizontalPadding) + leftPadding)
        self.dislikeLeftConstraint.constant = CGFloat((4 * horizontalPadding) + leftPadding)
        self.layoutIfNeeded()
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
        if !userVoted! {
            let defaults = UserDefaults.standard
            let token = defaults.string(forKey: "token")
            attemptVote(token: token!, postId: (post?.id)!, badgeId: 0)
        }
    }
    @IBAction func selectedNotAmusedBadge(_ sender: UIButton)
    {
        if !userVoted! {
            let defaults = UserDefaults.standard
            let token = defaults.string(forKey: "token")
            attemptVote(token: token!, postId: (post?.id)!, badgeId: 1)
        }
    }
    @IBAction func selectedHeartBadge(_ sender: UIButton)
    {
        if !userVoted! {
            let defaults = UserDefaults.standard
            let token = defaults.string(forKey: "token")
            attemptVote(token: token!, postId: (post?.id)!, badgeId: 2)
        }
    }
    @IBAction func selectedLikeBadge(_ sender: UIButton)
    {
        if !userVoted! {
            let defaults = UserDefaults.standard
            let token = defaults.string(forKey: "token")
            attemptVote(token: token!, postId: (post?.id)!, badgeId: 3)
        }
    }
    @IBAction func selectedDislikeBadge(_ sender: UIButton)
    {
        if !userVoted! {
            let defaults = UserDefaults.standard
            let token = defaults.string(forKey: "token")
            attemptVote(token: token!, postId: (post?.id)!, badgeId: 4)
        }
    }
    
}
