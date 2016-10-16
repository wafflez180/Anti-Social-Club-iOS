//
//  LoginViewController.swift
//  Anti-Social Club
//
//  Created by Declan Hopkins on 10/15/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController
{
    var userName : String?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "token")
        {
            attemptLogin(token: token)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func attemptLogin(token: String)
    {
        print("Attempting to login with token \(token)")
        
        let parameters = ["token" : token]

        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_LOGIN, method: .post, parameters: parameters)
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
                        self.onLoginFailure()

                        return
                    }
                
                    // User doesn't exist
                    if json["exists"].bool == false
                    {
                        self.onUserDoesNotExist()
                        
                        return
                    }
                
                    // Grab the user name
                    self.userName = json["name"].string
                
                    // User email isn't confirmed
                    if json["confirmed"].bool == false
                    {
                        self.onUserNotConfirmed()
                        
                        return
                    }
                    
                    // Authentication failed for one reason or another
                    // This would happen if you were banned or something
                    if json["authenticated"].bool == false
                    {
                        print("authentication failed, deleting token")
                        
                        // Now, we need to delete the local user token because it is obviously not valid.
                        UserDefaults.standard.removeObject(forKey: "token")
                        
                        self.onLoginFailure()
                        
                        return
                    }
                
                    self.onLoginSuccess()

                case .failure(let error):
                    print("Request failed with error: \(error)")
                    self.onLoginFailure()
                    
                    return
            }
        }
   
    }

    func onUserDoesNotExist()
    {
        print("User does not exist! We need to register!")
        performSegue(withIdentifier: "confirmNameSegue", sender: nil)
    }
    
    func onUserNotConfirmed()
    {
        print("User has not confirmed their email!")
        performSegue(withIdentifier: "confirmEmailSegue", sender: nil)
    }
    
    func onLoginSuccess()
    {
        print("login successful, going into message board now")
        performSegue(withIdentifier: "loginSuccessSegue", sender: nil)
    }
    
    func onLoginFailure()
    {
        print("Failed to login!")
        
        // TODO:
        // Display some sort of error message here. This method is called when there is a serverside error
        // or if it can't connect. On the Android version, it just makes a "NETWORK ERROR" show up in red text,
        // with a retry button.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "confirmEmailSegue")
        {
            let destination = segue.destination as! ConfirmEmailViewController
            destination.userName = userName
        }
    }

}
