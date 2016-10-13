//
//  ComposePostView.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/11/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit

class ComposePostView: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var mid2APView: UIView!
    @IBOutlet weak var mid1APView: UIView!
    @IBOutlet weak var rightAPView: UIView!
    @IBOutlet weak var leftAPView: UIView!
    @IBOutlet weak var photoButContBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightButtonsContainer: UIView!
    @IBOutlet weak var photoButtonsContainer: UIView!
    @IBOutlet weak var sendPostButtonBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var sendPostButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    var parentVC : HomepageTableViewController!
    var blurView : UIView!
    var showingPhotoButtons : Bool = false
    
    func viewDidLoad(){
        // Do any additional setup after loading the view, typically from a nib.
        
        self.messageTextField.delegate = self;
        applyPlainShadow(view: self)
        createGaussianBlur()
        setupFrame()
        setupAnimateButton()
        dismissPhotoButtonContainer(animate: false)
    }
    
    //MARK: - ComposePostView
    
    func setupFrame() {
        let frameHeight = 180.0 as CGFloat
        self.frame = CGRect.init(x: 0, y: self.parentVC.view.frame.height, width: self.parentVC.view.frame.size.width, height: frameHeight)
    }
    
    func setupAnimateButton() {
        var newFrame1 : CGRect = leftAPView.frame
        newFrame1.origin.x-=leftAPView.frame.size.height/4
        leftAPView.frame = newFrame1
        var newFrame2 : CGRect = rightAPView.frame
        newFrame2.origin.x+=rightAPView.frame.size.height/4
        rightAPView.frame = newFrame2

        leftAPView.transform = CGAffineTransform(rotationAngle: (CGFloat.pi/4))//-45 Degrees
        rightAPView.transform = CGAffineTransform(rotationAngle: -(CGFloat.pi/4))//45 Degrees
    }
    
    func animateButtonToX(){
        let animationSpeed : TimeInterval = 0.3
        
        //Set constant to half of the messageboxview
        self.sendPostButtonBotConstraint.constant = (self.rightButtonsContainer.frame.size.height/2)-(self.sendPostButton.frame.size.height/2)
        
        //Reposition the 2 middle views
        UIView.animate(withDuration: animationSpeed, delay: animationSpeed, options: .curveEaseInOut, animations:
            {
                var newFrame1 : CGRect = self.mid1APView.frame
                newFrame1.origin.x-=5
                newFrame1.origin.y=self.mid2APView.frame.origin.y
                self.mid1APView.frame = newFrame1
                var newFrame2 : CGRect = self.mid2APView.frame
                newFrame2.origin.x+=5
                self.mid2APView.frame = newFrame2
            },completion:
            { finished in

        })
        UIView.animate(withDuration: animationSpeed, delay: 0.0, options: .curveEaseInOut, animations:
            {
                //Change the constraints
                self.layoutIfNeeded()
                self.updateConstraints()
                self.addPhotoButton.alpha = 0.0
                //Rotate the views
                self.leftAPView.transform = CGAffineTransform(rotationAngle: -(CGFloat.pi/4))//-45
                self.rightAPView.transform = CGAffineTransform(rotationAngle: (CGFloat.pi/4))//45
                self.mid1APView.transform = CGAffineTransform(rotationAngle: (CGFloat.pi/4))//45
                self.mid2APView.transform = CGAffineTransform(rotationAngle: -(CGFloat.pi/4))//-45
            },completion:
            { finished in

        })
    }
    
    func animateButtonToArrow(){
        let animationSpeed : TimeInterval = 0.3
        self.sendPostButtonBotConstraint.constant = 25
        
        //Reset frames
        let newFrame1 = CGRect(x: 20, y: 10, width: 6, height: 17)
        let newFrame2 = CGRect(x: 20, y: 17, width: 6, height: 17)
        self.mid1APView.frame = newFrame1
        self.mid2APView.frame = newFrame2
        self.mid1APView.bounds = newFrame1
        self.mid2APView.bounds = newFrame2

        UIView.animate(withDuration: animationSpeed, delay: animationSpeed, options: .curveEaseInOut, animations:
            {
                self.mid1APView.frame = newFrame1
                self.mid2APView.frame = newFrame2
                self.mid1APView.bounds = newFrame1
                self.mid2APView.bounds = newFrame2
            },completion:
            { finished in

        })
        UIView.animate(withDuration: animationSpeed, delay: 0.0, options: .curveEaseInOut, animations:
            {
                //Change the constraints
                self.layoutIfNeeded()
                self.updateConstraints()
                self.addPhotoButton.alpha = 1.0
                //Rotate the views
                self.leftAPView.transform = CGAffineTransform(rotationAngle: (CGFloat.pi/4))//-45
                self.rightAPView.transform = CGAffineTransform(rotationAngle: -(CGFloat.pi/4))//45
                self.mid1APView.transform = CGAffineTransform.identity
                self.mid2APView.transform = CGAffineTransform.identity
            },completion:
            { finished in

        })
    }
    
    func dismissPhotoButtonContainer(animate: Bool){
        let popupHeight = 180.0 as CGFloat
        //Use 30 to avoid constraint conflicts (10, 10, 10 seperators for the buttons)
        photoContainerHeightConstraint.constant = 30
        //Hides the 30 height view
        photoButContBotConstraint.constant = -30

        showingPhotoButtons = false
        
        if(animate){
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations:
                {
                    //Reposition and decrease the height of the popup
                    self.frame = CGRect.init(x: 0, y: (self.parentVC.view.frame.height/2.5)-popupHeight/2, width: self.parentVC.view.frame.size.width, height: popupHeight)
                    self.photoButtonsContainer.alpha = 0.0
                    self.layoutIfNeeded()
                    self.updateConstraints()
                },completion:
                { finished in
            })
        }else{
            self.layoutIfNeeded()
            photoButtonsContainer.alpha = 0.0
        }
    }
    
    func presentPhotoButtonContainer(animate: Bool){
        let popupHeight = 380.0 as CGFloat
        self.photoContainerHeightConstraint.constant = 230
        //Hide the bottom rounded corners
        self.photoButContBotConstraint.constant = -10
        
        showingPhotoButtons = true

        if(animate){
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations:
                {
                    //Reposition and increase the height of the popup
                    self.frame = CGRect.init(x: 0, y: (self.parentVC.view.frame.height/2.5)-popupHeight/2, width: self.parentVC.view.frame.size.width, height: popupHeight)
                    self.photoButtonsContainer.alpha = 1.0
                    self.layoutIfNeeded()
                    self.updateConstraints()
                },completion:
                { finished in
            })
        }else{
        }
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
        let popupHeight = 180.0 as CGFloat
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
        if showingPhotoButtons {
            dismissPhotoButtonContainer(animate: true)
            animateButtonToArrow()
        }else{
            
        }
    }

    @IBAction func pressedAddPhoto(_ sender: UIButton) {
        if !showingPhotoButtons {
            presentPhotoButtonContainer(animate: true)
            animateButtonToX()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
