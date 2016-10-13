//
//  ComposePostView.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/11/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit

class ComposePostView: UIView, UITextFieldDelegate {
    
// CODE REVIEW:
// Your conventions with braces are a little screwy, they are inline someplaces and next line on others
// They should be on the next line, for everything.
// Functions, classes, whatever takes braces.
// You are probably asking, "why oh why do all these nuts put braces on the next line". Well, there is a
// reason for it. Javascript is a pretty fucked language. Way back in the day, it wouldn't compile unless you had
// your braces on the same line. So, one of the reasons why this convention was formed was because of a restriction
// of a bad language.
// Also, braces indicate a BLOCK of code. So when I see two braces, it just makes the most sense to see a block.
// If the first brace is up one line and all the way to the right, it's no longer a block. it's some sort of random
// shape. Okay, end rant
    
    
    // CODE REVIEW:
    // Where is the MARK: Properties?
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var sendPostButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    var parentVC : HomepageTableViewController!
    var blurView : UIView!
    
    func viewDidLoad(){
    
        // CODE REVIEW:
        // You can delete all of these pre-generated comments from the functions:
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.messageTextField.delegate = self;
        applyPlainShadow(view: self)
        createGaussianBlur()
        setupFrame()
    }
    
    //MARK: - ComposePostView
    
    func setupFrame() {
        let frameHeight = 160.0 as CGFloat
        self.frame = CGRect.init(x: 0, y: self.parentVC.view.frame.height, width: self.parentVC.view.frame.size.width, height: frameHeight)
    }

    
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 24
    }
    
    func createGaussianBlur(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.parentVC.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        blurView.alpha = 0.0
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        blurView.addGestureRecognizer(tap)

        self.parentVC.view.addSubview(blurView)
    }
    
    func presentPopup(){
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
    
    func dismissPopup(){
        // CODE REVIEW:
        // When you have code blocks defined inside function parameters, they should be on the same
        // indentation level as the call itself: Example:
        // myFunc(handler:
        // {
        //     CODE HERE
        // })
    
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
