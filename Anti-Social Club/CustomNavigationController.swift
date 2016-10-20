//
//  CustomNavigationController.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/18/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    var username : String?
    var userToken : String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
