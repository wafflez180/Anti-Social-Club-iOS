//
//  ConfirmKeyViewController.swift
//  Anti-Social Club
//
//  Created by Declan Hopkins on 10/15/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ConfirmKeyViewController: UIViewController
{
    var userName : String?

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if userName == nil
        {
            print("userName was nil in the ConfirmKeyViewController, no beuno. Did you pass it from the ConfirmNameViewController?")
            
            return
        }
        
        let key = "AAAA" // TODO: get key from user input
        attemptConfirmKey(name: userName!, key: key)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    func attemptConfirmKey(name : String, key : String)
    {
        print("Attempting to confirm key \(key) for user named \(name)")
        
        let parameters = ["name" : name, "key" : key]

        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_CONFIRM_KEY, method: .post, parameters: parameters)
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
                        self.onConfirmFailure()

                        return
                    }
                
                    // Key not valid
                    if json["success"].bool == false
                    {
                        self.onKeyNotValid()
                        
                        return
                    }
                
                    self.onConfirmSuccess()

                case .failure(let error):
                    print("Request failed with error: \(error)")
                    self.onConfirmFailure()
                    
                    return
            }
        }
    }
    
    func onConfirmSuccess()
    {
        print("Key was good! The user now exists in the database and a confirmation email has been sent. Next step!")
        performSegue(withIdentifier: "confirmEmailSegue", sender: nil)
    }
    
    func onConfirmFailure()
    {
        print("Failed to confirm key!")
        
        // TODO:
        // Display some sort of error message here. This method is called when there is a serverside error
        // or if it can't connect. On the Android version, it just makes a "NETWORK ERROR" show up in red text,
        // with a retry button.
    }
    
    func onKeyNotValid()
    {
        print("The key was not valid, either it was already used or it doesn't exist.")
        
        // TODO:
        // Display some sort of error message here.
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
