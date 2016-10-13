//
//  ComposePostView.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/11/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import UIKit
import AVFoundation
import Fusuma

class ComposePostView: UIView, FusumaDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var addCameraPhotoButton: UIButton!
    @IBOutlet weak var postPhotoImageView: UIImageView!
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
    
    // MARK: Properties
    var parentVC : HomepageTableViewController!
    var blurView : UIView!
    var showingPhotoButtons : Bool = false
    
    let fusuma = FusumaViewController()
    
    func viewDidLoad()
    {
        messageTextField.delegate = self
        fusuma.delegate = self
        fusuma.hasVideo = false // If you want to let the users allow to use video.
        fusumaTintColor = UIColor.getASCMediumColor()
        fusumaCropImage = true
        //fusumaBackgroundColor = UIColor.getASCMediumColor()
        applyPlainShadow(view: self)
        createGaussianBlur()
        setupFrame()
        setupAnimateButton()
        dismissPhotoButtonContainer(animate: false)
    }
    
    //MARK: - ComposePostView
    
    func setupFrame()
    {
        let frameHeight = 180.0 as CGFloat
        self.frame = CGRect.init(x: 0, y: self.parentVC.view.frame.height, width: self.parentVC.view.frame.size.width, height: frameHeight)
    }
    
    func setupAnimateButton()
    {
        var newFrame1 : CGRect = leftAPView.frame
        newFrame1.origin.x-=leftAPView.frame.size.height/4
        leftAPView.frame = newFrame1
        var newFrame2 : CGRect = rightAPView.frame
        newFrame2.origin.x+=rightAPView.frame.size.height/4
        rightAPView.frame = newFrame2
        
        leftAPView.transform = CGAffineTransform(rotationAngle: (CGFloat.pi/4))//-45 Degrees
        rightAPView.transform = CGAffineTransform(rotationAngle: -(CGFloat.pi/4))//45 Degrees
    }
    
    func animateButtonToX()
    {
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
    
    func animateButtonToArrow()
    {
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
    
    func dismissPhotoButtonContainer(animate: Bool)
    {
        let popupHeight = 180.0 as CGFloat
        //Use 30 to avoid constraint conflicts (10, 10, 10 seperators for the buttons)
        photoContainerHeightConstraint.constant = 30
        //Hides the 30 height view
        photoButContBotConstraint.constant = -30
        
        showingPhotoButtons = false
        
        if(animate)
        {
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
        }else
        {
            self.layoutIfNeeded()
            photoButtonsContainer.alpha = 0.0
        }
    }
    
    func presentPhotoButtonContainer(animate: Bool)
    {
        let popupHeight = 380.0 as CGFloat
        self.photoContainerHeightConstraint.constant = 230
        //Hide the bottom rounded corners
        self.photoButContBotConstraint.constant = -10
        
        showingPhotoButtons = true
        
        if(animate)
        {
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
        }else
        {
        }
    }
    
    func applyPlainShadow(view: UIView)
    {
        let layer = view.layer
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 24
    }
    
    func createGaussianBlur()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.parentVC.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        blurView.alpha = 0.0
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        blurView.addGestureRecognizer(tap)
        
        self.parentVC.view.addSubview(blurView)
    }
    
    func presentPopup()
    {
        //Animate post view to the middle of the screen
        let popupHeight = 180.0 as CGFloat
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp, animations:
            {
                self.blurView.alpha = 1.0
                self.frame = CGRect.init(x: 0, y: (self.parentVC.view.frame.height/2)-popupHeight, width: self.parentVC.view.frame.size.width, height: popupHeight)
            },completion:
            { finished in
                print("Finished animation")
        })
    }
    
    func dismissPopup()
    {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp, animations:
            {
                self.blurView.alpha = 0.0
                self.frame = CGRect.init(x: 0, y: self.parentVC.view.frame.height, width: self.parentVC.view.frame.size.width, height: self.frame.size.height)
                
            },completion:
            { finished in
                self.blurView.removeFromSuperview()
                self.removeFromSuperview()
        })
    }
    
    func resetImageView(animate: Bool){
        addCameraPhotoButton.isHidden = false
        addCameraPhotoButton.alpha = 0.3
        postPhotoImageView.alpha = 1.0
        if animate
        {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp, animations:
                {
                    self.addCameraPhotoButton.alpha = 1.0
                    self.postPhotoImageView.alpha = 0.0
                },completion:
                { finished in
                    self.postPhotoImageView.image = nil
                    self.postPhotoImageView.alpha = 1.0
            })
        }else{
            addCameraPhotoButton.isHidden = false
            postPhotoImageView.image = nil
            self.addCameraPhotoButton.alpha = 1.0
            self.postPhotoImageView.alpha = 1.0
        }
    }
    
    func flashMessageBox(){
        self.messageTextField.layer.borderColor = UIColor.red.cgColor
        
        let flashSpeed = 0.2
        
        UIView.animate(withDuration: flashSpeed, delay: 0.0, options: .transitionCurlDown, animations:
            {
                self.messageTextField.layer.borderWidth = 2
                //self.messageTextField.layer.borderColor = UIColor.clear.cgColor
        })
        UIView.animate(withDuration: flashSpeed, delay: flashSpeed, options: .transitionCurlDown, animations:
            {
                self.messageTextField.layer.borderWidth = 0
                //self.messageTextField.layer.borderColor = UIColor.clear.cgColor
        })
    }
    
    func sendPost(){
        //TODO: Make A spinner in the send button and then make a check mark or something then:
        if (messageTextField.text?.isEmpty)!
        {
            flashMessageBox()
        }else{
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp, animations:
                {
                    self.blurView.alpha = 0.0
                    self.frame = CGRect.init(x: 0, y: -self.frame.size.height, width: self.parentVC.view.frame.size.width, height: self.frame.size.height)
                },completion:
                { finished in
                    self.blurView.removeFromSuperview()
                    self.removeFromSuperview()
            })
        }
    }
    
    // MARK: - UITextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - Actions
    
    @IBAction func pressedSendPost(_ sender: UIButton)
    {
        if showingPhotoButtons && postPhotoImageView.image == nil
        {
            dismissPhotoButtonContainer(animate: true)
            animateButtonToArrow()
        }else
        {
            sendPost()
        }
    }
    
    @IBAction func pressedAddPhoto(_ sender: UIButton)
    {
        if !showingPhotoButtons
        {
            presentPhotoButtonContainer(animate: true)
            animateButtonToX()
        }else{
            resetImageView(animate: true)
            animateButtonToX()
        }
    }
    
    @IBAction func getPhoto(_ sender: AnyObject) {
        let authStatus : AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if(authStatus == AVAuthorizationStatus.authorized)
        {
            self.parentVC.present(self.fusuma, animated: true, completion: nil)
        } else if(authStatus == AVAuthorizationStatus.denied)
        {
            // denied
            pressedSendPost(sender as! UIButton)
        } else if(authStatus == AVAuthorizationStatus.restricted)
        {
            // restricted, normally won't happen
            pressedSendPost(sender as! UIButton)
        } else if(authStatus == AVAuthorizationStatus.notDetermined)
        {
            // not determined?!
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo)
            { granted in
                if(granted)
                {
                    print("Granted access to " + AVMediaTypeVideo);
                    self.parentVC.present(self.fusuma, animated: true, completion: nil)
                } else
                {
                    print("Not granted access to " + AVMediaTypeVideo);
                    self.pressedSendPost(sender as! UIButton)
                }
            }
        }
    }
    
    // MARK: - Fusuma
    
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(_ image: UIImage)
    {
        print("Image selected")
        postPhotoImageView.contentMode = .scaleAspectFit
        postPhotoImageView.image = image
        addCameraPhotoButton.isHidden = true
        animateButtonToArrow()
        //parentVC.dismiss(animated: true, completion: nil)
    }

    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(_ image: UIImage)
    {
        
        print("Called just after FusumaViewController is dismissed.")
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL)
    {
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized()
    {
        print("Camera roll unauthorized")
        
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
