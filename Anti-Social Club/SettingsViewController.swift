//
//  SettingsViewController.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/15/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SettingsViewController: UIViewController {

    @IBOutlet weak var funnyBadgeLabel: UILabel!
    @IBOutlet weak var notamusedBadgeLabel: UILabel!
    @IBOutlet weak var heartBadgeLabel: UILabel!
    @IBOutlet weak var likeBadgeLabel: UILabel!
    @IBOutlet weak var dislikeBadgeLabel: UILabel!
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var dateJoinedLabel: UILabel!
    
    // MARK - SettingsViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveUserInfo()
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

    @IBAction func pressedOnDeactivateDevice(_ sender: AnyObject) {
        let deactivateAlert = UIAlertController(title: "Deactivate Device", message: "Are you sure you want to deactivate your device? To activate another device you’ll need to confirm your email again", preferredStyle: UIAlertControllerStyle.alert)
        
        deactivateAlert.addAction(UIAlertAction(title: "Deactivate", style: .destructive, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
        }))
        
        deactivateAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(deactivateAlert, animated: true, completion: nil)
    }
    
    func retrieveUserInfo()
    {
        let token = UserDefaults.standard.string(forKey: "token")!
        let parameters = ["token" : token]

        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_RETRIEVE_USER_INFO, method: .post, parameters: parameters)
        .responseJSON()
        {
            response in

            switch response.result
            {
                case .success(let responseData):
                    let json = JSON(responseData)

                    // Handle any errors
                    if json["error"].bool == true
                    {
                        print("ERROR: \(json["error_message"].stringValue)")
                        return
                    }

                    // Parse returned user info
                    if (json["user_info"].dictionary != nil)
                    {
                        let userInfoJSON = json["user_info"].dictionary!
                        
                        let rankId : Int = userInfoJSON["rank"]!.intValue
                        let creationTimeStamp   : String = userInfoJSON["creation_timestamp"]!.stringValue
                        let badgeFunnyCount     : Int = userInfoJSON["badge_funny_count"]!.intValue
                        let badgeDumbCount      : Int = userInfoJSON["badge_dumb_count"]!.intValue
                        let badgeLoveCount      : Int = userInfoJSON["badge_love_count"]!.intValue
                        let badgeAgreeCount     : Int = userInfoJSON["badge_agree_count"]!.intValue
                        let badgeDisagreeCount  : Int = userInfoJSON["badge_disagree_count"]!.intValue
                        
                        print("Got user info! Rank id is \(rankId)")
                        
                        return
                    }
                
                    print("Test")

                case .failure(let error):
                    print("Request failed with error: \(error)")
                    return
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
