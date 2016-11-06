//
//  networkErrorViewController.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 11/6/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit

class networkErrorViewController: UIViewController {
    
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var networkErrorBodyLabel: UILabel!
    @IBOutlet weak var networkErrorTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isToolbarHidden = true
        self.navigationController?.navigationBar.isHidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func pressedRetry(_ sender: Any) {
        performSegue(withIdentifier: "toEntryViewSegue", sender: sender)
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
