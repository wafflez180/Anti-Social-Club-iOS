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
import Alamofire
import SwiftyJSON

class ComposePostView: UIView, FusumaDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageFieldContainer: UIView!
    @IBOutlet weak var postPhotoImageView: UIImageView!
    @IBOutlet weak var photoButContBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightButtonsContainer: UIView!
    @IBOutlet weak var photoButtonsContainer: UIView!
    @IBOutlet weak var sendPostButtonBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var sendPostButton: UIButton!
    
    // MARK: Properties
    var parentVC : HomepageTableViewController!
    var blurView : UIView!
    var showingPhotoButtons : Bool = false
    var imageToUpload : UIImage?
    var keyboardIsHidden = true
    
    let fusuma = FusumaViewController()
    
    func viewDidLoad()
    {
        messageTextView.delegate = self
        fusuma.delegate = self
        fusuma.hasVideo = false // If you want to let the users allow to use video.
        fusumaTintColor = UIColor.getASCMediumColor()
        fusumaCropImage = true
        //fusumaBackgroundColor = UIColor.getASCMediumColor()
        applyPlainShadow(view: self)
        createGaussianBlur()
        setupFrame()
        dismissPhotoButtonContainer(animate: false)
        
        self.photoButtonsContainer.isUserInteractionEnabled = true
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentFullImageView))
        self.photoButtonsContainer.addGestureRecognizer(tap)
        
        // Listen for keyboard appearances and disappearances
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(keyboardDidShow),
        name: NSNotification.Name.UIKeyboardDidShow,
        object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide),
            name: NSNotification.Name.UIKeyboardDidHide,
            object: nil)
    }
    
    //MARK: - ComposePostView
    
    func presentFullImageView(){
        if self.imageToUpload != nil && parentVC != nil {
            parentVC.selectedImage = imageToUpload
            parentVC.performSegue(withIdentifier: "viewFullImageSegue", sender: nil)
        }
    }
    
    func keyboardDidShow(notification: NSNotification)
    {
        keyboardIsHidden = false
    }
    
    func keyboardDidHide(notification: NSNotification)
    {
        keyboardIsHidden = true
    }
    
    func setupFrame()
    {
        let frameHeight = 180.0 as CGFloat
        self.frame = CGRect.init(x: 0, y: self.parentVC.tableView.contentOffset.y + (self.parentVC.tableView.frame.height), width: self.parentVC.view.frame.size.width, height: frameHeight)
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
                    self.frame = CGRect.init(x: 0, y: self.parentVC.tableView.contentOffset.y + (self.parentVC.tableView.frame.height/2)-(popupHeight/2), width: self.parentVC.view.frame.size.width, height: popupHeight)
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
                    self.frame = CGRect.init(x: 0, y: self.parentVC.tableView.contentOffset.y + (self.parentVC.tableView.frame.height/2)-(popupHeight/1.5), width: self.parentVC.view.frame.size.width, height: popupHeight)
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
        //Stop scrolling
        self.parentVC.tableView.isScrollEnabled = false
        self.parentVC.tableView.setContentOffset(self.parentVC.tableView.contentOffset, animated: false)
        
        //Animate post view to the middle of the screen
        let popupHeight = 180.0 as CGFloat
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp, animations:
            {
                self.blurView.alpha = 1.0
                self.frame = CGRect.init(x: 0, y: self.parentVC.tableView.contentOffset.y + (self.parentVC.tableView.frame.height/2)-(popupHeight/2), width: self.parentVC.view.frame.size.width, height: popupHeight)
            },completion:
            { finished in
                print("Dismissed Compose Message Popup")
        })
    }
    
    func dismissPopup()
    {
        if keyboardIsHidden
        {
            self.parentVC.composePostPopup = nil
            self.parentVC.tableView.isScrollEnabled = true
            self.parentVC.navigationController?.setToolbarHidden(false, animated: true)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp, animations:
                {
                    self.blurView.alpha = 0.0
                    self.frame = CGRect.init(x: 0, y: self.parentVC.tableView.contentOffset.y + (self.parentVC.tableView.frame.height), width: self.parentVC.view.frame.size.width, height: self.frame.size.height)
                },completion:
                { finished in
                    self.blurView.removeFromSuperview()
                    self.removeFromSuperview()
            })
        }else
        {
            self.endEditing(true)
        }
    }
    
    func resetImageView(animate: Bool)
    {
        //addCameraPhotoButton.isHidden = false
        //addCameraPhotoButton.alpha = 0.3
        postPhotoImageView.alpha = 1.0
        if animate
        {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp, animations:
                {
                    //self.addCameraPhotoButton.alpha = 1.0
                    self.postPhotoImageView.alpha = 0.0
                },completion:
                { finished in
                    self.postPhotoImageView.image = nil
                    self.postPhotoImageView.alpha = 1.0
            })
        }else
        {
            //addCameraPhotoButton.isHidden = false
            postPhotoImageView.image = nil
            //self.addCameraPhotoButton.alpha = 1.0
            self.postPhotoImageView.alpha = 1.0
        }
    }
    
    func flashMessageBox()
    {
        let origColor = self.messageFieldContainer.backgroundColor
        let flashSpeed = 0.5
        
        UIView.animate(withDuration: flashSpeed, animations:
        {
            self.messageFieldContainer.backgroundColor = UIColor.red.withAlphaComponent(0.7)
            }, completion: { Finished in
                UIView.animate(withDuration: flashSpeed, animations:
                    {
                    self.messageFieldContainer.backgroundColor = origColor
                })
        })
    }
    
    func sendPost()
    {
        //TODO: Make A spinner in the send button and then make a check mark or something then:
        if (messageTextView.text?.isEmpty)!
        {
            flashMessageBox()
        }else
        {
            let message = messageTextView.text!;
            let token = UserDefaults.standard.string(forKey: "token")!
        
            Alamofire.upload(
            multipartFormData:
            {
                multipartFormData in
                
                if let image = self.imageToUpload {
                    if let imageData = UIImageJPEGRepresentation(image, 0.1) {
                        print("Got imageData, appending to multipartFormData...")
                        multipartFormData.append(imageData, withName: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
                    }
                }
                
                multipartFormData.append(message.data(using: String.Encoding.utf8)!, withName: "message")
                multipartFormData.append(token.data(using: String.Encoding.utf8)!, withName: "token")
            },
            to: Constants.API.ADDRESS + Constants.API.CALL_POST,
            method: .post,
            encodingCompletion:
            {
                encodingResult in
                
                switch encodingResult
                {
                    case .success(let upload, _, _):
                        upload.responseJSON()
                        {
                            response in

                            switch response.result
                            {
                                case .success(let responseData):
                                    let json = JSON(responseData)

                                    // Handle any errors
                                    if json["error"].bool == true
                                    {
                                        print("ERROR: \(json["error_message"].stringValue)")
                                        return
                                    }else if json["silenced"].bool == true{
                                        let alert = UIAlertController(title: "Silenced", message: "You are silenced, and are not allowed to post or comment.", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                        self.parentVC.present(alert, animated: true, completion: nil)
                                    }else{
                                        self.sendPopupAnimation()
                                    }
                                    break
                                
                                case .failure(let error):
                                    print("Request failed with error: \(error)")
                            }
                        }

                    case .failure(let encodingError):
                        print("Image encoding failed: \(encodingError)");
                }
            }
            );
        }
    }
    
    func sendPopupAnimation(){
        self.parentVC.tableView.isScrollEnabled = true
        self.parentVC.composePostPopup = nil
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp, animations:
            {
                self.blurView.alpha = 0.0
                self.frame = CGRect.init(x: 0, y: self.parentVC.tableView.contentOffset.y - (self.parentVC.tableView.frame.height), width: self.parentVC.view.frame.size.width, height: self.frame.size.height)
                
            },completion:
            { finished in
                self.blurView.removeFromSuperview()
                self.removeFromSuperview()
        })
    }
    
    func getPhoto()
    {
        let authStatus : AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if(authStatus == AVAuthorizationStatus.authorized)
        {
            DispatchQueue.main.async {
                self.parentVC.present(self.fusuma, animated: true, completion: nil)
            }
        } else if(authStatus == AVAuthorizationStatus.denied)
        {
            // denied
            //pressedSendPost(sender as! UIButton)
        } else if(authStatus == AVAuthorizationStatus.restricted)
        {
            // restricted, normally won't happen
            //pressedSendPost(sender as! UIButton)
        } else if(authStatus == AVAuthorizationStatus.notDetermined)
        {
            // not determined?!
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo)
            { granted in
                if(granted)
                {
                    print("Granted access to " + AVMediaTypeVideo);
                    
                    DispatchQueue.main.async {
                        self.parentVC.present(self.fusuma, animated: true, completion: nil)
                    }
                } else
                {
                    print("Not granted access to " + AVMediaTypeVideo);
                    //self.pressedSendPost(sender as! UIButton)
                }
            }
        }
    }
    
    func cropTo16by9Center(image: UIImage) -> UIImage {
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let cgwidth: CGFloat = CGFloat(contextImage.size.width)
        let cgheight: CGFloat = CGFloat(Float(contextImage.size.width)/(16.0/9.0))
        let posX: CGFloat = 0.0
        let posY: CGFloat = CGFloat(contextImage.size.height/2.0) - (cgheight/2)
        /*
         print("Image Size\n\tWidth: \(image.size.width)\n\tHeight: \(image.size.height)")
         print("Context Image Size\n\tWidth: \(contextImage.size.width)\n\tHeight: \(contextImage.size.height)")
         print("16:9 Image Size\n\tWidth: \(cgwidth)\n\tHeight: \(cgheight)")
         */
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    // MARK: - UITextView
    
    // Set Character limit
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        let currentCharacterCount = textView.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        
        if(text == "\n"){
            textView.resignFirstResponder()
            textView.endEditing(true)
            return false
        }

        return newLength <= 200
    }
    
    
    // MARK: - Actions
    
    @IBAction func pressedSendPost(_ sender: UIButton)
    {
        if showingPhotoButtons && postPhotoImageView.image == nil
        {
            dismissPhotoButtonContainer(animate: true)
            //animateButtonToArrow()
        }else
        {
            sendPost()
        }
    }
    
    @IBAction func pressedAddPhoto(_ sender: UIButton)
    {
        if !showingPhotoButtons
        {
            getPhoto()
            //presentPhotoButtonContainer(animate: true)
            //animateButtonToX()
        }else{
            resetImageView(animate: true)
            dismissPhotoButtonContainer(animate: true)
            addPhotoButton.isSelected = false
            imageToUpload = nil
            //animateButtonToX()
        }
    }
    
    // MARK: - Fusuma
    
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(_ image: UIImage)
    {
        print("Image selected")
        postPhotoImageView.contentMode = .scaleAspectFill
        postPhotoImageView.image = cropTo16by9Center(image: image)
        imageToUpload = image
        presentPhotoButtonContainer(animate: true)
        addPhotoButton.isSelected = true
        //addCameraPhotoButton.isHidden = true
        //animateButtonToArrow()
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
