//
//  ComposePostView.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/11/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit

class ComposePostView: UIView, UITextFieldDelegate {
    
    
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var sendPostButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    var parentVC : HomepageTableViewController!
    var blurView : UIView!
    
    func viewDidLoad(){
        // Do any additional setup after loading the view, typically from a nib.
        
        self.messageTextField.delegate = self;
        applyPlainShadow(view: self)
    }
    
    //MARK: - ComposePostView
    
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 24
    }
    
    func setupGaussianBlur(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.parentVC.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        blurView.alpha = 0.0
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(animateBackInComposePostPopup))
        blurView.addGestureRecognizer(tap)

        self.parentVC.view.addSubview(blurView)
    }
    
    func animateInComposePostPopup(){
        //Animate post view to the middle of the screen
        let popupHeight = 160.0 as CGFloat
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .transitionCurlUp, animations:
            {
                self.blurView.alpha = 1.0
                self.frame = CGRect.init(x: 0, y: (self.parentVC.view.frame.height/2)-popupHeight, width: self.parentVC.view.frame.size.width, height: popupHeight)
                
            },completion:
            { finished in
                print("Finished animation")
        })
    }
    
    func animateBackInComposePostPopup(){
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .transitionCurlUp, animations:
            {
                self.blurView.alpha = 0.0
                self.frame = CGRect.init(x: 0, y: self.parentVC.view.frame.height, width: self.parentVC.view.frame.size.width, height: self.frame.size.height)
                
            },completion:
            { finished in
                self.blurView.removeFromSuperview()
                self.removeFromSuperview()
        })
    }
    
    // MARK: - UITextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - Actions
    
    @IBAction func pressedSendPost(_ sender: UIButton) {
        
    }

    @IBAction func pressedAddPhoto(_ sender: UIButton) {
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
