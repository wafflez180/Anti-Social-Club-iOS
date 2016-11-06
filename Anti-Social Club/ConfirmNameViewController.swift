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

class ConfirmNameViewController: UIViewController, UITextFieldDelegate
{
    var userName : String?

    @IBOutlet weak var ubitNameTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var errorTextView: UITextView!
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        ubitNameTextField.delegate = self
        // This view controller's responsibility is to get the users UBIT name, and then send it to the server
        // to check if it is valid. Then, we can continue.
        
        // TESTING:
        //let name = "declanho" // TODO: Get this from user input
        //attemptConfirmName(name: name)
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
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityView.center=submitButton.center
        activityView.frame = submitButton.frame
        activityView.startAnimating()
        submitButton.superview?.addSubview(activityView)
        submitButton.isHidden = true
        
        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_CONFIRM_NAME, method: .post, parameters: parameters)
            .responseJSON()
                {
                    response in
                    
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                    self.submitButton.isHidden = false
                    
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
                        
                        self.onConfirmSuccess()
                        
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        self.onConfirmFailure()
                        self.performSegue(withIdentifier: "networkErrorSegue", sender: self)
                        
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
        errorTextView.text = "Sorry!\nUser is not allowed."
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
        errorTextView.text = "Network Error!\nPlease try again later!"
        // TODO:
        // Display some sort of error message here. This method is called when there is a serverside error
        // or if it can't connect. On the Android version, it just makes a "NETWORK ERROR" show up in red text,
        // with a retry button.
    }
    
    // MARK: - TextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 32 // Bool
    }

    // MARK: - Actions

    @IBAction func submitUBITName(_ sender: AnyObject) {
        attemptConfirmName(name: removeUnWantedCharsFromString(text: ubitNameTextField.text!))
    }
    
    func removeUnWantedCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890".characters)
        return String(text.characters.filter {okayChars.contains($0) })
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
            destination.errorText = "User already exists!\nPlease enter the code in your verification email."
        }
    }


}
