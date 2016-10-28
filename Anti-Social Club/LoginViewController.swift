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
import Onboard

class LoginViewController: UIViewController
{
    var userName : String?
    var userToken : String?
    var firstPage : OnboardingContentViewController?
    var secondPage : OnboardingContentViewController?
    var thirdPage : OnboardingContentViewController?
    var fourthPage : OnboardingContentViewController?
    var onboardingVC : OnboardingViewController?

    override func viewDidLoad()
    {
        super.viewDidLoad()

        userToken = UserDefaults.standard.string(forKey: "token")
        if userToken != nil
        {
            attemptLogin(token: userToken!)
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
        //performSegue(withIdentifier: "loginSuccessSegue", sender: nil)
        // Image
        
        firstPage = OnboardingContentViewController(title: "Post", body: "Post images and/or text with\nfull anonymity", image: UIImage(named: "firstTutorialImage"), buttonText: "Next") { () -> Void in
            // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
            self.transitionToNextVC(index: 0)
        }
        
        secondPage = OnboardingContentViewController(title: "Comment", body: "When you comment you are given a\nrandom color for that post", image: UIImage(named: "secondTutorialImage"), buttonText: "Next") { () -> Void in
            // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
            self.transitionToNextVC(index: 1)
        }
        thirdPage = OnboardingContentViewController(title: "Vote", body: "Vote your opinion on posts to\nreveal how many voted", image: UIImage(named: "thirdTutorialImage"), buttonText: "Next") { () -> Void in
            // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
            self.transitionToNextVC(index: 2)
        }
        fourthPage = OnboardingContentViewController(title: "Share Keys", body: "Go to the settings page to share\nthe few keys you have", image: UIImage(named: "fourthTutorialImage"), buttonText: "Enter") { () -> Void in
            self.dismiss(animated: true, completion: {
                
            })
            self.performSegue(withIdentifier: "loginSuccessSegue", sender: nil)
        }

        onboardingVC = OnboardingViewController(backgroundImage: UIImage(named: "backgroundTutorialImage"), contents: [firstPage!,secondPage!,thirdPage!,fourthPage!])

        let contentControllers = (onboardingVC?.viewControllers as! [OnboardingContentViewController])
        
        let titleTopPadding : CGFloat = 40
        for onboardVC : OnboardingContentViewController in contentControllers {
            onboardVC.topPadding = self.view.frame.size.height-firstPage!.iconHeight;
            onboardVC.underIconPadding = -firstPage!.topPadding + -firstPage!.iconHeight + titleTopPadding;
            onboardVC.underTitlePadding = 10;
            onboardVC.bottomPadding = 0

            onboardVC.titleLabel.textColor = UIColor.hexStringToUIColor(hex: "B2EBF2")
            onboardVC.titleLabel.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightRegular)
            onboardVC.bodyLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
            onboardVC.actionButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
        }
        firstPage?.actionButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        onboardingVC?.pageControl.isHidden = true
        onboardingVC?.swipingEnabled = false
        
        onboardingVC?.shouldMaskBackground = false
        
        present(onboardingVC!, animated: true)
    }
    
    func transitionToNextVC(index : Int){
        onboardingVC?.moveNextPage()
        if index == 0 {
            firstPage?.view.alpha = 1.0
            secondPage?.view.alpha = 0.0
            UIView.animate(withDuration: 0.3, animations: {
                self.firstPage?.view.alpha = 0.0
                self.secondPage?.view.alpha = 1.0
            })
        }else if index == 1{
            secondPage?.view.alpha = 1.0
            thirdPage?.view.alpha = 0.0
            UIView.animate(withDuration: 0.3, animations: {
                self.secondPage?.view.alpha = 0.0
                self.thirdPage?.view.alpha = 1.0
            })
        }else if index == 2{
            thirdPage?.view.alpha = 1.0
            fourthPage?.view.alpha = 0.0
            UIView.animate(withDuration: 0.3, animations: {
                self.thirdPage?.view.alpha = 0.0
                self.fourthPage?.view.alpha = 1.0
            })
        }
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
            destination.errorText = "You Still Need To Verify Your Email!"
        }else if (segue.identifier == "loginSuccessSegue"){
            let destination = segue.destination as! CustomNavigationController
            destination.username = userName!
            destination.userToken = userToken!
        }

    }

}
