//
//  ViewImageViewController.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/25/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit

class ViewImageViewController: UIViewController {

    @IBOutlet weak var fullImageView: UIImageView!
    
    var fullSizeImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fullImageView.image = fullSizeImage!
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedView(_ sender: Any) {
        dismiss(animated: true)
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
