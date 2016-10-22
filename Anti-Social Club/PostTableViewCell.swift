//
//  PostTableViewCell.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/10/16.
//  Copyright © 2016 Cult of the Old Gods. All rights reserved.
//

import UIKit

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
    
    var id : Int?
    var posterId : Int?
    var message : String?
    var imageSource : String?
    var userVoted : Bool?
    var userVotedBadge : Int?
    var userReported : Bool?
    var reportCount : Int?
    var commentCount : Int?
    var loadedContent : Bool = false

    func configureCellWithPost(post: Post) {
        loadedContent = true
        messageLabel.text = post.message
        userReported = post.reported
        userVoted = post.voted
        userVotedBadge = post.votedBadge
        imageSource = post.imageSource
        id = post.id
        posterId = post.posterId
        
        let tempDateFormatter = DateFormatter()
        tempDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
        tempDateFormatter.locale = Locale(identifier: "en_US")
        
        let creationDate = tempDateFormatter.date(from: post.timestamp!)
        setTimestamp(withDateCreated: creationDate!)
        
        laughingBadgeButton.titleLabel!.text = String(describing: post.badgeFunnyCount!)
        notAmusedBadgeButton.titleLabel!.text = String(describing: post.badgeDumbCount!)
        heartBadgeButton.titleLabel!.text = String(describing: post.badgeLoveCount!)
        likeBadgeButton.titleLabel!.text = String(describing: post.badgeAgreeCount!)
        dislikeBadgeButton.titleLabel!.text = String(describing: post.badgeDisagreeCount!)
        commentButton.titleLabel!.text = String(describing: post.commentCount!)
        reportButton.titleLabel!.text = String(describing: post.reportCount!)
        
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
    
    // MARK: - IBActions

    @IBAction func viewComments(_ sender: UIButton) {
    }
    @IBAction func report(_ sender: UIButton)
    {
        
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
