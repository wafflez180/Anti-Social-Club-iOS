//
//  ToSViewController.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 11/9/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit

class ToSViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var agreeButton: UIButton!
    
    var loginParentVC : LoginViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        let url = NSURL (string: "https://ub-anti-social.club/tos");
        let requestObj = NSURLRequest(url: url! as URL);
        webView.loadRequest(requestObj as URLRequest);
        
        agreeButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        agreeButton.isEnabled = true
    }
    
    @IBAction func userAgreedToTerms(_ sender: Any) {
        print("User accepted the terms of service")
        UserDefaults.standard.set(true, forKey: "acceptedTos")
        dismiss(animated: true, completion: {
            self.loginParentVC?.onLoginSuccess()
        })
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
