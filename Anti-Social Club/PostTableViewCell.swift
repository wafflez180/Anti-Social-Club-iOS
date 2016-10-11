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
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, message: String?, timestamp: String, laughingBadgeCount: Int, notAmusedBadgeCount: Int, heartBadgeCount: Int, likeBadgeCount: Int, dislikeBadgeCount: Int) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        messageLabel.text = message
        timestampLabel.text = timestamp
        laughingBadgeButton.titleLabel!.text = String(laughingBadgeCount)
        notAmusedBadgeButton.titleLabel!.text = String(notAmusedBadgeCount)
        heartBadgeButton.titleLabel!.text = String(heartBadgeCount)
        likeBadgeButton.titleLabel!.text = String(likeBadgeCount)
        dislikeBadgeButton.titleLabel!.text = String(dislikeBadgeCount)
    }
    
    //After composing post
    init(style: UITableViewCellStyle, reuseIdentifier: String?, message: String?, timestamp: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        messageLabel.text = message
        timestampLabel.text = timestamp
        laughingBadgeButton.titleLabel!.text = "0"
        notAmusedBadgeButton.titleLabel!.text = "0"
        heartBadgeButton.titleLabel!.text = "0"
        likeBadgeButton.titleLabel!.text = "0"
        dislikeBadgeButton.titleLabel!.text = "0"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
