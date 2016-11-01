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

class ConfirmKeyViewController: UIViewController, UITextFieldDelegate
{
    var userName : String?
    var errorText : String?

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var accessKeyTextField: UITextField!
    @IBOutlet weak var errorTextView: UITextView!
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        accessKeyTextField.delegate = self
        
        if userName == nil
        {
            print("userName was nil in the ConfirmKeyViewController, no beuno. Did you pass it from the ConfirmNameViewController?")
            
            return
        }
        
        if (errorText != nil) {
            errorTextView.text = errorText
        }
        
        //let key = "AAAA" // TODO: get key from user input
        //attemptConfirmKey(name: userName!, key: key)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    func attemptConfirmKey(name : String, key : String)
    {
        print("Attempting to confirm key \(key) for user named \(name)")
        
        let parameters = ["name" : name, "key" : key]

        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityView.center=submitButton.center;
        activityView.frame = submitButton.frame
        activityView.startAnimating()
        submitButton.superview?.addSubview(activityView)
        submitButton.isHidden = true

        Alamofire.request(Constants.API.ADDRESS + Constants.API.CALL_CONFIRM_KEY, method: .post, parameters: parameters)
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
        errorTextView.text = "Network Error!\nPlease try again later!"
        // TODO:
        // Display some sort of error message here. This method is called when there is a serverside error
        // or if it can't connect. On the Android version, it just makes a "NETWORK ERROR" show up in red text,
        // with a retry button.
    }
    
    func onKeyNotValid()
    {
        print("The key was not valid, either it was already used or it doesn't exist.")
        errorTextView.text = "Sorry!\nKey not exist\nOr\nKey has been used"
        // TODO:
        // Display some sort of error message here.
    }
    
    // MARK: - TextField

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 8 // Bool
    }

    
    // MARK: - Actions
    
    @IBAction func submitAccessKey(_ sender: AnyObject) {
        attemptConfirmKey(name: userName!, key: accessKeyTextField.text!)
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
