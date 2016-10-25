//
//  CommentTableViewCell.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/23/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    var postCell : PostTableViewCell?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithComment(comment: Comment){
        //If the user who made the post, made this comment
        if comment.posterId == self.postCell?.post?.posterId {
            colorView.backgroundColor = UIColor.hexStringToUIColor(hex: "00BCD4")
            commentLabel.textColor = UIColor.hexStringToUIColor(hex: "00BCD4")
            commentLabel.font =  UIFont.systemFont(ofSize: commentLabel.font.pointSize, weight: UIFontWeightSemibold)
        }else{
            colorView.backgroundColor = UIColor.hexStringToUIColor(hex: comment.color!)
            commentLabel.textColor = UIColor.hexStringToUIColor(hex: "4E4E4E")
            commentLabel.font =  UIFont.systemFont(ofSize: commentLabel.font.pointSize, weight: UIFontWeightRegular)
        }
        commentLabel.text = comment.message
        timestamp.text = comment.timestamp
        
        let tempDateFormatter = DateFormatter()
        tempDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        tempDateFormatter.timeZone = TimeZone(identifier: "GMT")
        
        let creationDate = tempDateFormatter.date(from: comment.timestamp!)
        setTimestamp(withDateCreated: creationDate!)
            }
    
    func setTimestamp(withDateCreated : Date){
        let currentDate = Date()
                
        self.timestamp.numberOfLines=0
        if(currentDate.months(from: withDateCreated) > 0){
            self.timestamp.text = "\(currentDate.months(from: withDateCreated))mts"
        }else if(currentDate.weeks(from: withDateCreated) > 0){
            self.timestamp.text = "\(currentDate.weeks(from: withDateCreated))w"
        }else if(currentDate.days(from: withDateCreated) > 0){
            self.timestamp.text = "\(currentDate.days(from: withDateCreated))d"
        }else if(currentDate.hours(from: withDateCreated) > 0){
            self.timestamp.text = "\(currentDate.hours(from: withDateCreated))h"
        }else if(currentDate.minutes(from: withDateCreated) > 0){
            self.timestamp.text = "\(currentDate.minutes(from: withDateCreated))m"
        }else if(currentDate.seconds(from: withDateCreated) > 0){
            self.timestamp.text = "\(currentDate.seconds(from: withDateCreated))s"
        }else{
            self.timestamp.text = "0s"
        }
    }
}
