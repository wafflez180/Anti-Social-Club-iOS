//
//  ConncetViewController.swift
//  Anti-Social Club
//
//  Created by Declan Hopkins on 10/15/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController
{
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        // This view controller doesn't do anything visually. It's just the entrypoint of the
        // app, where the app decides if the user can attempt to login immediatly, or if they
        // need to register.

        // First, check and see if the user has a token (string) stored on the device (NSUserDefaults)
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "token") != nil
        {
            // If there is a token, then we can attempt to login.
            print("User token was found! Going to login.")
            print("Token is \(defaults.string(forKey: "token"))")
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
        else
        {
            // Okay, there's no token. We can start the "registration" process
            print("No user token found. User needs to register this device.")
            performSegue(withIdentifier: "confirmNameSegue", sender: nil)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
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
