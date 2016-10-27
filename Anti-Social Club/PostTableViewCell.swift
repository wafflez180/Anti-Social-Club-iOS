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
    
    @IBOutlet weak var laughingTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var notAmusedTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var heartTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var disklikeTopConstraint: NSLayoutConstraint!
    
    var userVoted : Bool?
    var userVotedBadge : Int?
    var userReported : Bool?
    var loadedContent : Bool = false
    var post : Post?
    var parentVC : HomepageTableViewController!
    var section : Int?
    var commentViewCont : CommentViewController?
    var voteButtonArray : [UIButton] = []
    var voteButtonLeftConstraintArray : [NSLayoutConstraint] = []
    var voteButtonTopConstraintArray : [NSLayoutConstraint] = []

    func configureCellWithPost(post: Post, section: Int) {
        loadedContent = true
        messageLabel.text = post.message
        userReported = post.reported
        userVoted = post.voted
        userVotedBadge = post.votedBadge
        self.post = post
        self.section = section
        
        voteButtonArray = [laughingBadgeButton,notAmusedBadgeButton,heartBadgeButton,likeBadgeButton,dislikeBadgeButton]
        voteButtonLeftConstraintArray = [laughingLeftConstraint,notAmusedLeftConstraint,heartLeftConstraint,likeLeftConstraint,dislikeLeftConstraint]
        voteButtonTopConstraintArray = [laughingTopConstraint,notAmusedTopConstraint,heartTopConstraint,likeTopConstraint,disklikeTopConstraint]
        
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
            self.imageViewHeightContraint.constant = 211
            let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentFullImageView))
            self.postImageView.addGestureRecognizer(tap)
            if post.downloadedImage == nil {
                self.postImageView.image = nil
                retrieveImage();
            }else{
                self.postImageView.image = cropTo16by9Center(image: post.downloadedImage!)
            }
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
    
    func retrieveImage() {
        Alamofire.request(Constants.API.ADDRESS + Constants.API.IMAGE_DIRECTORY + post!.imageSource!).responseImage
        {
            response in
            
            if let image : UIImage = response.result.value
            {
                self.postImageView.alpha = 0.0
                self.postImageView.image = self.cropTo16by9Center(image: image)
                UIView.animate(withDuration: 0.2, animations: {
                    self.postImageView.alpha = 1.0
                })

                self.layoutSubviews()
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
    
    func cropTo16by9Center(image: UIImage) -> UIImage {
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let cgwidth: CGFloat = CGFloat(contextImage.size.width)
        let cgheight: CGFloat = CGFloat(Float(contextImage.size.width)/(16.0/9.0))
        let posX: CGFloat = 0.0
        let posY: CGFloat = CGFloat(contextImage.size.height/2.0) - (cgheight/2)
        /*
        print("Image Size\n\tWidth: \(image.size.width)\n\tHeight: \(image.size.height)")
        print("Context Image Size\n\tWidth: \(contextImage.size.width)\n\tHeight: \(contextImage.size.height)")
        print("16:9 Image Size\n\tWidth: \(cgwidth)\n\tHeight: \(cgheight)")
        */
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
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
        if self.post?.downloadedImage != nil {
            parentVC.selectedImage = self.post?.downloadedImage
            parentVC.performSegue(withIdentifier: "viewFullImageSegue", sender: nil)
        }
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
                        self.post?.reported = true
                        self.post?.reportCount = (self.post?.reportCount)!+1
                        
                        //Update cell in the main page
                        if self.commentViewCont != nil {
                            self.commentViewCont?.parentVC?.selectedPostCell?.configureCellWithPost(post: (self.post)!, section: (self.commentViewCont?.parentVC?.selectedPostCell?.section)!)
                        }

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
                            self.post?.badgeFunnyCount = (self.post?.badgeFunnyCount)! + 1
                            self.laughingBadgeButton.setTitle(String(describing: (self.post?.badgeFunnyCount!)!), for: UIControlState.normal)
                        case 1:
                            self.post?.badgeDumbCount = (self.post?.badgeDumbCount)! + 1
                            self.notAmusedBadgeButton.setTitle(String(describing: (self.post?.badgeDumbCount!)!), for: UIControlState.normal)
                        case 2:
                            self.post?.badgeLoveCount = (self.post?.badgeLoveCount)! + 1
                            self.heartBadgeButton.setTitle(String(describing: (self.post?.badgeLoveCount!)!), for: UIControlState.normal)
                        case 3:
                            self.post?.badgeAgreeCount = (self.post?.badgeAgreeCount)! + 1
                            self.likeBadgeButton.setTitle(String(describing: (self.post?.badgeAgreeCount!)!), for: UIControlState.normal)
                        case 4:
                            self.post?.badgeDisagreeCount = (self.post?.badgeDisagreeCount)! + 1
                            self.dislikeBadgeButton.setTitle(String(describing: (self.post?.badgeDisagreeCount!)!), for: UIControlState.normal)
                        default :
                            print("Error")
                        }
                        
                        self.selectBadge(badgeId: badgeId, animate: true)
                        
                        self.post?.voted = true
                        self.userVoted = true
                        self.post?.votedBadge = badgeId
                        self.userVotedBadge = badgeId
                        
                        //Update cell in the main page
                        if self.commentViewCont != nil {
                            self.commentViewCont?.parentVC?.selectedPostCell?.configureCellWithPost(post: (self.post)!, section: (self.commentViewCont?.parentVC?.selectedPostCell?.section)!)
                        }
                        
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        
                        return
                    }
        }
    }
    
    func badgeExplodeAnimation(button : UIButton){
        var explodeDuplicatesArray : [UIImageView] = []
        for _ in 0...14 {
            let tempImageView : UIImageView = UIImageView(image: button.image(for: UIControlState.selected))
            var tempImageFrame : CGRect = CGRect()
            var pointInTableView = CGPoint()
            
            if parentVC == nil {
                pointInTableView = self.convert(button.frame.origin, to: self.commentViewCont?.commentTableview)
                self.commentViewCont?.commentTableview.addSubview(tempImageView)
            }else{
                pointInTableView = self.convert(button.frame.origin, to: self.parentVC.tableView)
                self.parentVC.tableView.addSubview(tempImageView)
            }
            //Set initial frame
            
            //print(self.parentVC.tableView.contentOffset.y)
            //print(tempImageFrame.origin.y)
            tempImageFrame.origin.y = pointInTableView.y
            tempImageFrame.origin.x = button.frame.origin.x
            tempImageFrame.size = button.frame.size
            tempImageView.frame = tempImageFrame

            explodeDuplicatesArray+=[tempImageView]
        }
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .transitionCurlDown, animations: {
            for duplicate in explodeDuplicatesArray {
                var randomX = Int(arc4random_uniform(75))
                let randomY = Int(arc4random_uniform(75))
                let randomSpin = Int(arc4random_uniform(8)+1)
                duplicate.frame.origin.y = CGFloat(duplicate.frame.origin.y + CGFloat(randomY))
                if randomX < 80/2 {
                    randomX = randomX * -1
                }
                duplicate.frame.origin.x = CGFloat(duplicate.frame.origin.x + CGFloat(randomX))
                duplicate.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4)*CGFloat(randomSpin))
            }
        },completion: { finished in
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlDown, animations: {
                for duplicate in explodeDuplicatesArray {
                    duplicate.alpha = 0.0
                }
            },completion: { finished in
                for duplicate in explodeDuplicatesArray {
                    duplicate.removeFromSuperview()
                }
            })
        }
        )
    }
    
    func selectBadge(badgeId: Int, animate: Bool){
        voteButtonArray[badgeId].isSelected = true
        voteButtonArray[badgeId].titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        
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
        var animationTime = 0.0
        if animate == false{
            animationTime = 0.0
        }else{
            animationTime = 0.5
            self.badgeExplodeAnimation(button: self.voteButtonArray[badgeId])
        }
        
        let topPadding : CGFloat = 6.0
        UIView.animate(withDuration: animationTime, animations: {
            for button in buttonsToDisappear{
                button.alpha = 0.0
            }
            for (index, buttonToMove) in buttonsToMove.enumerated(){
                //Bring buttons up and to the left
                for (indexToMove, button) in self.voteButtonArray.enumerated(){
                    if button == buttonToMove{
                        self.voteButtonTopConstraintArray[indexToMove].constant = self.voteButtonTopConstraintArray[indexToMove].constant - topPadding
                        self.voteButtonLeftConstraintArray[indexToMove].constant = CGFloat((index * horizontalPadding) + leftPadding)
                    }
                }
    
                if buttonToMove.isSelected == false{
                    buttonToMove.alpha = 0.5
                }
                
                buttonToMove.titleLabel?.alpha = 1.0
            }
            self.layoutIfNeeded()
            
        },completion: { finished in

        })
    }
    
    func resetBadges(){
        let leftPadding = 5
        let horizontalPadding = 40

        for (index, button) in voteButtonArray.enumerated() {
            button.isSelected = false
            button.alpha = 1.0
            button.titleLabel?.alpha = 0.0
            voteButtonLeftConstraintArray[index].constant = CGFloat((index * horizontalPadding) + leftPadding)
        }
        let topPadding : CGFloat = 6.0
        voteButtonTopConstraintArray[0].constant = 6.0 + topPadding
        voteButtonTopConstraintArray[1].constant = 6.0 + topPadding
        voteButtonTopConstraintArray[2].constant = 10.0 + topPadding
        voteButtonTopConstraintArray[3].constant = 9.0 + topPadding
        voteButtonTopConstraintArray[4].constant = 9.0 + topPadding
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
            if self.parentVC == nil {
                self.commentViewCont?.present(deactivateAlert, animated: true, completion: nil)
            }else{
                self.parentVC.present(deactivateAlert, animated: true, completion: nil)
            }
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
        //print("Heart LocY: \(self.convert(heartBadgeButton.frame.origin, to: self.parentVC.tableView))")
        //badgeExplodeAnimation(button: heartBadgeButton)
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
