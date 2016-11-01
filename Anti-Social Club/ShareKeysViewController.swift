//
//  ShareKeysViewController.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/18/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Crashlytics

class ShareKeysViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var keyArray : [AccessKey] = []
    var recipientTextField: UITextField!

    @IBOutlet weak var keysTableView: UITableView!
    @IBOutlet weak var buyMoreKeysButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keysTableView.delegate = self
        keysTableView.dataSource = self
        
        let defaults = UserDefaults.standard
        attemptRetrieveUserKeys(token: defaults.string(forKey: "token")!)
        
        //TODO Take off alpha when implemented functionality
        buyMoreKeysButton.alpha = 0.3

        // Do any additional setup after loading the view.
        Answers.logContentView(
            withName: "Key View",
            contentType: "View",
            contentId: "Key",
            customAttributes: [:])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func attemptRetrieveUserKeys(token : String)
    {
        print("Attempting to retrieve keys from token: \(token)")
        
        let parameters = ["token" : token]
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityView.center=self.view.center;
        activityView.frame = self.view.frame
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_RETRIEVE_USER_KEYS, method: .post, parameters: parameters)
            .responseJSON()
                {
                    response in
                    
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    
                    switch response.result
                    {
                    case .success(let responseData):
                        let json = JSON(responseData)
                        
                        // Handle any errors
                        if json["error"].bool == true
                        {
                            print("ERROR: \(json["error_message"].stringValue)")
                            let alert = UIAlertController(title: "Error", message: "Network Error! Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            
                            return
                        }
                        
                        let jsonArray = json["keys"].array
                        for subJSON in jsonArray!
                        {
                            if let key : AccessKey = AccessKey(json: subJSON)
                            {
                                self.keyArray+=[key]
                            }
                            
                        }
                        self.keysTableView.reloadData()
                        
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        let alert = UIAlertController(title: "Error", message: "Network Error! Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)

                        return
                    }
        }
    }
    
    func attemptSendKey(token : String, key : String, recipientEmail : String)
    {
        print("Attempting to send key\n\tKey: \(key)\n\tTo: \(recipientEmail)")
        
        let parameters = ["token" : token, "key" : key, "recipient_email" : recipientEmail]
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityView.center=self.view.center;
        activityView.frame = self.view.frame
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_SEND_INVITE, method: .post, parameters: parameters)
            .responseJSON()
                {
                    response in
                    
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    
                    switch response.result
                    {
                    case .success(let responseData):
                        let json = JSON(responseData)
                        //Don't do anything if it succesfully went through
                        let alert = UIAlertController(title: "Success!", message: "You're key was sent to \(recipientEmail)", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        Answers.logInvite(withMethod: "Email Key", customAttributes: [:])
                        
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        let alert = UIAlertController(title: "Error", message: "Network Error! Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        return
                    }
        }
    }

    
    // MARK: - Actions
    
    @IBAction func pressedPurchaseMoreKeys(_ sender: AnyObject) {
        print("Pressed On Purchase More Keys")
        //TODO Purchase more keys popup
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return keyArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "keyCell", for: indexPath) as! ShareKeyTableViewCell
        
        cell.configureCellWithKey(key: keyArray[indexPath.section])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ShareKeyTableViewCell
        
        if !cell.isRedeemed! {
            let alert = UIAlertController(title: "Share Key", message: "Please enter your friend's email address.", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: configurationTextField)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:handleCancel))
            alert.addAction(UIAlertAction(title: "Share", style: .default, handler:{ (UIAlertAction) in
                print("User shared key: \(cell.accessKey!) to \(self.recipientTextField.text!)")
                let defaults = UserDefaults.standard
                self.attemptSendKey(token: defaults.string(forKey: "token")!, key: cell.accessKey!, recipientEmail: self.recipientTextField.text!)
            }))
            self.present(alert, animated: true, completion: {
                print("completion block")
            })
            cell.setSelected(false, animated: true)
        }
    }
    
    func configurationTextField(textField: UITextField!)
    {
        print("Generating TextField")
        textField.placeholder = "friend@buffalo.edu"
        recipientTextField = textField
    }
    
    func handleCancel(alertView: UIAlertAction!)
    {
        print("Cancelled")
    }
    
   /* -(void)handleKeyboardWillShow:(NSNotification *)sender{
    CGSize keyboardSize = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.bottomBar.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height);
*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
