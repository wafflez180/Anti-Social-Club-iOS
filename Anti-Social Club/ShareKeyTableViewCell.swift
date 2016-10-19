//
//  ShareKeyTableViewCell.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/18/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShareKeyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var accessKeyLabel: UILabel!
    @IBOutlet weak var shareIcon: UIImageView!
    @IBOutlet weak var bgContentView: UIView!
    
    var isRedeemed : Bool?
    var accessKey : String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellWithKey(key: AccessKey){
        self.accessKey = key.accessKey
        self.isRedeemed = key.isRedeemed
        
        accessKeyLabel.text = self.accessKey
        if self.isRedeemed! {
            self.selectionStyle = UITableViewCellSelectionStyle.none
            shareIcon.isHidden = true
            bgContentView.alpha = 0.50
            accessKeyLabel.textColor.withAlphaComponent(0.5)
        }
    }
}
