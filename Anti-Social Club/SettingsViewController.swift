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
import Crashlytics
import FirebaseMessaging
import Firebase

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var funnyBadgeLabel: UILabel!
    @IBOutlet weak var notamusedBadgeLabel: UILabel!
    @IBOutlet weak var heartBadgeLabel: UILabel!
    @IBOutlet weak var likeBadgeLabel: UILabel!
    @IBOutlet weak var dislikeBadgeLabel: UILabel!
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var dateJoinedLabel: UILabel!
    
    @IBOutlet weak var enableNotificationsLabel: UILabel!
    @IBOutlet weak var enableNotificationSwitch: UISwitch!
    
    @IBOutlet weak var miscellaneousTableView: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var segueingToDeactivate : Bool = false
    var userToken : String?
    var recipientTextField: UITextField!

    // MARK - SettingsViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miscellaneousTableView.delegate = self
        miscellaneousTableView.dataSource = self
        
        retrieveUserInfo()
        
        userToken = (self.navigationController as! CustomNavigationController).userToken
        
        let disabledNotifications = UserDefaults.standard.bool(forKey: "disabledNotifications")
        if disabledNotifications {
            enableNotificationSwitch.isOn = false
            enableNotificationsLabel.isHighlighted = false
        }else{
            enableNotificationSwitch.isOn = true
            enableNotificationsLabel.isHighlighted = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.size.height + (self.navigationController?.navigationBar.frame.height)! + 38)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !(self.navigationController?.toolbar.isHidden)! {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if  !segueingToDeactivate && (self.navigationController?.toolbar.isHidden)! {
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                            
                            self.funnyBadgeLabel.text = String(badgeFunnyCount)
                            self.notamusedBadgeLabel.text = String(badgeDumbCount)
                            self.heartBadgeLabel.text = String(badgeLoveCount)
                            self.likeBadgeLabel.text = String(badgeAgreeCount)
                            self.dislikeBadgeLabel.text = String(badgeDisagreeCount)
                            
                            if rankId == 0 {
                                self.rankLabel.text = "Member"
                            }else if rankId == 1 {
                                self.rankLabel.text = "Pioneer"
                            }else if rankId == 2 {
                                self.rankLabel.text = "Moderator"
                            }else if rankId == 3 {
                                self.rankLabel.text = "Administrator"
                            }
                            
                            let tempDateFormatter = DateFormatter()
                            tempDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            tempDateFormatter.timeZone = TimeZone(identifier: "GMT")
                            tempDateFormatter.locale = Locale(identifier: "en_US")
                            
                            let creationDate = tempDateFormatter.date(from: creationTimeStamp)
                            
                            let shortDateFormatter = DateFormatter()
                            shortDateFormatter.dateStyle = DateFormatter.Style.short
                            tempDateFormatter.timeZone = TimeZone(identifier: "GMT")
                            shortDateFormatter.locale = Locale(identifier: "en_US")
                            self.dateJoinedLabel.text = shortDateFormatter.string(from: creationDate!)
                            
                            print("Got user info! Rank id is \(rankId)")
                            
                            return
                        }
                        
                        print("Test")
                        
                    case .failure(let error):
                        (self.navigationController as! CustomNavigationController).networkError()
                        print("Request failed with error: \(error)")
                        return
                    }
        }
    }
    
    func registerFCMToken(fcmToken : String)
    {
        let token = "\(userToken!)"
        let parameters = ["token" : token, "fcm_token" : fcmToken, "fcm_platform" : "iOS"]
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_REGISTER_FCM_TOKEN, method: .post, parameters: parameters)
            .responseJSON()
                {
                    response in
                    
                    self.enableNotificationSwitch.isEnabled = true
                    
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
                        
                        LOG("FCM token registered with server!")
                        
                    case .failure(let error):
                        (self.navigationController as! CustomNavigationController).networkError()
                        print("Request failed with error: \(error)")
                        
                        return
                    }
        }
    }
    
    func connectToFCM() {
        LOG("Connecting to FCM..");
        
        FIRMessaging.messaging().connect {
            (error) in
            
            if (error != nil) {
                LOG("Failed to connect to FCM! \(error)")
            } else {
                LOG("Connected to FCM.")
                if let fcmToken = FIRInstanceID.instanceID().token()
                {
                    LOG("Got FCM token \(fcmToken) at login")
                    self.registerFCMToken(fcmToken : "\(fcmToken)")
                }
                else
                {
                    LOG("Didn't get an FCM token at login!")
                }
            }
        }
    }

    // MARK - Actions
    
    @IBAction func disableNotificationsSwitch(_ sender: Any) {
        if enableNotificationSwitch.isOn{
            enableNotificationsLabel.isHighlighted = true
            connectToFCM()
            enableNotificationSwitch.isEnabled = false
            UserDefaults.standard.set(false, forKey: "disabledNotifcations")
        }else{
            enableNotificationsLabel.isHighlighted = false
            enableNotificationSwitch.isEnabled = false
            registerFCMToken(fcmToken: "")
            FIRMessaging.messaging().disconnect()
            LOG("Disconnected from FCM.")
            UserDefaults.standard.set(true, forKey: "disabledNotifcations")
        }
    }

    @IBAction func pressedOnDeactivateDevice(_ sender: AnyObject) {
        let deactivateAlert = UIAlertController(title: "Deactivate Device", message: "Are you sure you want to deactivate your device? To activate another device you’ll need to confirm your email again", preferredStyle: UIAlertControllerStyle.alert)
        
        deactivateAlert.addAction(UIAlertAction(title: "Deactivate", style: .destructive, handler: { (action: UIAlertAction!) in
            print("User Deactivated Account")
            self.segueingToDeactivate = true
            Answers.logCustomEvent(withName: "Deactivate", customAttributes: [:])
            self.attemptToDeactivate()
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "token")
            self.navigationController?.popViewController(animated: false)
            self.performSegue(withIdentifier: "confirmNameDeactivateSegue", sender: nil)
        }))
        
        deactivateAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(deactivateAlert, animated: true, completion: nil)
    }
    
    func attemptToDeactivate()
    {
        print("Attempting to deactivate user with token: \(userToken!)")
        
        let parameters = ["token" : userToken!]
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_DEACTIVATE_USER, method: .post, parameters: parameters)
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
                        
                    case .failure(let error):
                        (self.navigationController as! CustomNavigationController).networkError()
                        print("Request failed with error: \(error)")
                        
                        return
                    }
        }
    }
    
    func configurationTextField(textField: UITextField!)
    {
        print("Generating TextField")
        textField.placeholder = "message"
        recipientTextField = textField
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        
        if indexPath.row == 0 {
            //"Privacy Policy"
            UIApplication.shared.openURL(NSURL(string: "https://ub-anti-social.club/privacypolicy")! as URL)
        } else if indexPath.row == 1 {
            //"Terms and Conditions"
            UIApplication.shared.openURL(NSURL(string: "https://ub-anti-social.club/tos")! as URL)
        } else if indexPath.row == 2 {
            //"Contact Us"
            let alert = UIAlertController(title: "Contact Us", message: "Please enter your message for us.", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: configurationTextField)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Send", style: .default, handler:{ (UIAlertAction) in
                print("User sent message: \(self.recipientTextField.text!) to us")
                let defaults = UserDefaults.standard
                self.attemptContactUs(token: defaults.string(forKey: "token")!, message: self.recipientTextField.text!)
            }))
            self.present(alert, animated: true, completion: {
                print("completion block")
            })
        }
    }
    
    func attemptContactUs(token : String, message : String){
        let parameters = ["token" : token, "message" : message]
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_CONTACT_US_REQUEST, method: .post, parameters: parameters)
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
                        
                        let alert = UIAlertController(title: "Success", message: "Your message has been sent to us!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        print("Sent message to us: \(message)")
                        
                        
                    case .failure(let error):
                        (self.navigationController as! CustomNavigationController).networkError()
                        print("Request failed with error: \(error)")
                        
                        return
                    }
        }
    }

    //MARK - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Privacy Policy"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Terms and Conditions"
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "Contact Us"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        /*if (segue.identifier == "shareKeySegue")
        {
            let destination = segue.destination as! ShareKeysViewController
            segueingToShareKeyVC = true
        }*/
    }
    

}
