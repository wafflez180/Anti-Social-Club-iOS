//
//  ConfirmNameViewController.swift
//  Anti-Social Club
//
//  Created by Declan Hopkins on 10/15/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ConfirmNameViewController: UIViewController
{
    var userName : String?

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // This view controller's responsibility is to get the users UBIT name, and then send it to the server
        // to check if it is valid. Then, we can continue.
        
        // TESTING:
        let name = "declanho" // TODO: Get this from user input
        attemptConfirmName(name: name)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func attemptConfirmName(name: String)
    {
        // Save the name so we can pass it when we succeed
        userName = name
        
        let parameters = ["name" : name]

        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_CONFIRM_NAME, method: .post, parameters: parameters)
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
                
                    // User exists
                    if json["exists"].bool == true
                    {
                        self.onUserExists()
                        
                        return
                    }
                
                    // User is not allowed
                    if json["allowed"].bool == false
                    {
                        self.onUserNotAllowed()
                        
                        return
                    }

                case .failure(let error):
                    print("Request failed with error: \(error)")
                    self.onConfirmFailure()
                    
                    return
            }
        }
    }
    
    func onUserExists()
    {
        print("User already exists! Let them confirm their email key again.")
        performSegue(withIdentifier: "confirmEmailSegue", sender: nil)
    }
    
    func onUserNotAllowed()
    {
        print("User is not allowed (Not a student or banned)! Sorry!")
        
        // TODO:
        // Display an error message of some sort.
    }
    
    func onConfirmSuccess()
    {
        print("User doesn't exist and the user is allowed to join! Time to confirm their access key!")
        performSegue(withIdentifier: "confirmKeySegue", sender: nil)
    }
    
    func onConfirmFailure()
    {
        print("Failed to confirm name!")
        
        // TODO:
        // Display some sort of error message here. This method is called when there is a serverside error
        // or if it can't connect. On the Android version, it just makes a "NETWORK ERROR" show up in red text,
        // with a retry button.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "confirmKeySegue")
        {
            let destination = segue.destination as! ConfirmKeyViewController
            destination.userName = userName
        }
        else if (segue.identifier == "confirmEmailSegue")
        {
            let destination = segue.destination as! ConfirmEmailViewController
            destination.userName = userName
        }
    }


}
