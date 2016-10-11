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
    
    func configureCellWithPost(post: Post) {
        messageLabel.text = post.message
        timestampLabel.text = post.timestamp
        laughingBadgeButton.titleLabel!.text = String(describing: post.laughingBadgeCount)
        notAmusedBadgeButton.titleLabel!.text = String(describing: post.notAmusedBadgeCount)
        heartBadgeButton.titleLabel!.text = String(describing: post.heartBadgeCount)
        likeBadgeButton.titleLabel!.text = String(describing: post.likeBadgeCount)
        dislikeBadgeButton.titleLabel!.text = String(describing: post.dislikeBadgeCount)
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
