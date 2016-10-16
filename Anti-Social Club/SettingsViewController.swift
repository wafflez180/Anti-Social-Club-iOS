//
//  SettingsViewController.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/15/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var funnyBadgeLabel: UILabel!
    @IBOutlet weak var notamusedBadgeLabel: UILabel!
    @IBOutlet weak var heartBadgeLabel: UILabel!
    @IBOutlet weak var likeBadgeLabel: UILabel!
    @IBOutlet weak var dislikeBadgeLabel: UILabel!
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var dateJoinedLabel: UILabel!
    
    // MARK - SettingsViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedOnDeactivateDevice(_ sender: AnyObject) {
        let deactivateAlert = UIAlertController(title: "Deactivate Device", message: "Are you sure you want to deactivate your device? To activate another device you’ll need to confirm your email again", preferredStyle: UIAlertControllerStyle.alert)
        
        deactivateAlert.addAction(UIAlertAction(title: "Deactivate", style: .destructive, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
        }))
        
        deactivateAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(deactivateAlert, animated: true, completion: nil)
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
