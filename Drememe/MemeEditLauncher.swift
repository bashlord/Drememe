//
//  MemeLauncher.swift
//  Rendezvous2
//
//  Created by John Jin Woong Kim on 2/14/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import UIKit
import AVFoundation

// 175 pixels from top, 80/80 w/h

func imageWithImage(image:UIImage, scaledToSize size:CGSize ) -> UIImage {
    let hasAlpha = false
    let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
    
    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
    image.draw(in: CGRect(origin: .zero, size: size))
    
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage!
}

var memeFont = [
    NSStrokeColorAttributeName: UIColor.black,
    NSForegroundColorAttributeName: UIColor.white,
    NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40.0)!,
    NSStrokeWidthAttributeName : -4.0
    ] as [String : Any]

class MemeEditLauncherView: UIView{
    var launcher: MemeEditLauncher?

    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        
        print("frame parameters:: ", frame.width, frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MemeEditLauncher: NSObject, UITextViewDelegate {
    var view = MemeEditLauncherView()
    var currentFontSize: CGFloat = 40.0
    //imageView that holds the meme blank resized to fit the screen
    var imageView = UIImageView()
    // the original blank template image to be used when saving the text
    var originalImage: UIImage?
    //max height allowed for UIImage on the screen so it does not overlap with the buttons
    // button height = 80, trailing height = 16
    // screen.height-16-80
    var heightLimit: CGFloat?
    //calculated height for imageView to best fit the width to height ratio of the selected image
    var height: CGFloat?
    // height offset for sliding the views up/down
    var heightOffset: CGFloat = 0.0
    //picWidth/picHeight can be replaced with imageView.frame.width/imageView.frame.height since they are the same
    //var picWidth: CGFloat = 0.0
    //var picHeight: CGFloat = 0.0
    
    //not sure if i need this
    var selectedTextView: UITextView?
    
    var image: UIImage? {
        didSet {
            if let image = image{
                self.image = image
            }
        }
    }
    
    var path:String? {
        didSet {
            if path != nil{
                self.originalImage = UIImage(imageLiteralResourceName: path!)
            }
        }
    }
    
    lazy var topText: UITextView = {
        let textView = UITextView()
        textView.typingAttributes = memeFont
        textView.textAlignment = .center
        textView.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        textView.text = "TOP"
        textView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        textView.returnKeyType = .done
        return textView
    }()
    
    lazy var bottomText: UITextView = {
        let textView = UITextView()
        textView.typingAttributes = memeFont
        textView.textAlignment = .center
        textView.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        textView.text = "BOTTOM"
        textView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        textView.returnKeyType = .done
        return textView
    }()
    
    //flags:
    // 2 = cancel
    // 3 = check
    // 4 = small cancel
    // 5 = small clear
    // 6 = small save
    
    lazy var cancelButton: ButtonLauncher = {
        let b = ButtonLauncher()
        b.memeEditLauncher = self
        b.setFlag(flag: 2)
        return b
    }()
    
    lazy var startButton: ButtonLauncher = {
        let b = ButtonLauncher()
        b.memeEditLauncher = self
        b.setFlag(flag: 3)
        return b
    }()
    
    lazy var sCancelButton: ButtonLauncher = {
        let b = ButtonLauncher()
        b.memeEditLauncher = self
        b.setFlag(flag: 4)
        return b
    }()
    
    lazy var sClearButton: ButtonLauncher = {
        let b = ButtonLauncher()
        b.memeEditLauncher = self
        b.setFlag(flag: 5)
        return b
    }()
    
    lazy var sSaveButton: ButtonLauncher = {
        let b = ButtonLauncher()
        b.memeEditLauncher = self
        b.setFlag(flag: 6)
        return b
    }()
    
    // Button toggling
    
    func toggleCancelStartButtons(flag: Int){
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            if flag == 0{//toggle in
                self.cancelButton.frame.origin.x += 96
                self.startButton.frame.origin.x -= 176
            }else{//toggle out
                self.cancelButton.frame.origin.x -= 96
                self.startButton.frame.origin.x += 176
            }
        }) { (completed: Bool) in }
    }
    
    func toggleCancelClearEditButtons(flag: Int){
        if flag == 0{//toggle in
            self.sCancelButton.frame.origin.x += 96
            self.sSaveButton.frame.origin.x -= 176
            self.sClearButton.frame.origin.y -= 96
        }else{//toggle out
            self.sCancelButton.frame.origin.x -= 96
            self.sSaveButton.frame.origin.x += 176
            self.sClearButton.frame.origin.y += 95
        }
    }
    
    /////////////////////////////////////////////////
    
    // adding the meme image as well as the initial cancel/start button
    fileprivate func setupMemeView(view: UIView, frame: CGRect, img: UIImage, keyFrame: CGRect){
        imageView.frame = frame
        imageView.image = img
        
        self.view.addSubview(imageView)
        self.view.addConstraintsWithFormat("V:|-\((heightLimit!/2)-(frame.height/2))-[v0]", views: imageView)
        
        self.startButton.collectionView.layer.cornerRadius = 40
        self.startButton.frame = CGRect(x: keyFrame.width + 80, y: (keyFrame.height)-96, width: 80, height: 80)
        self.view.addSubview(self.startButton)
        
        self.cancelButton.collectionView.layer.cornerRadius = 40
        self.cancelButton.frame = CGRect(x: 0 - 80, y: (keyFrame.height)-96, width: 80, height: 80)
        self.view.addSubview(self.cancelButton)
        
        //left bottom +175
        self.sCancelButton.collectionView.layer.cornerRadius = 40
        self.sCancelButton.frame = CGRect(x: 0 - 80, y: ((heightLimit!/2)-(frame.height/2)+keyFrame.height)-96, width: 80, height: 80)
        self.view.addSubview(self.sCancelButton)
        
        //center bottom +175
        self.sClearButton.collectionView.layer.cornerRadius = 40
        self.sClearButton.frame = CGRect(x: (keyFrame.width/2) - 40, y: ((heightLimit!/2)-(frame.height/2)+keyFrame.height), width: 80, height: 80)
        self.view.addSubview(self.sClearButton)
        
        //right bottom +175
        self.sSaveButton.collectionView.layer.cornerRadius = 40
        self.sSaveButton.frame = CGRect(x: keyFrame.width + 80, y: ((heightLimit!/2)-(frame.height/2)+keyFrame.height)-96, width: 80, height: 80)
        self.view.addSubview(self.sSaveButton)
    }
    
    func expandMemeView(){
        if let keyWindow = UIApplication.shared.keyWindow {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            //setup keyboard handler
            tap.cancelsTouchesInView = false
            self.heightLimit = keyWindow.frame.height-16-80
            view.addGestureRecognizer(tap)
            
            view.launcher = self
            view.backgroundColor = UIColor.black
            view.frame = CGRect(x: 0, y: keyWindow.frame.height-10, width: keyWindow.frame.width, height: 10)
            
            //set memeView's frame, which will be holding the image to half the
            // height of the window frame height and the same width as the window
            height = ((originalImage?.size.height)!*keyWindow.frame.width)/(originalImage?.size.width)!
            if (height! > heightLimit!){
                height = heightLimit
            }else if (height! < heightLimit!/2){
                height = heightLimit!/2
            }
            let memeFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height!)
            
            //resize any image to be able to fit the memeFrame with respect to the
            // image's ratio, then set the image to the memeView's image
            let fittedImage = imageWithImage(image: self.image!, scaledToSize: CGSize(width: memeFrame.width, height: memeFrame.height))
            //init the view, adding the image, cancel, and edit buttons to subview
            heightOffset = (heightLimit!/2)-(memeFrame.height/2)
            setupMemeView(view: self.view, frame: memeFrame, img: fittedImage, keyFrame: keyWindow.frame)
            keyWindow.addSubview(view)
            
            let tempFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.frame = tempFrame
            }, completion: { (completedAnimation) in
                //maybe we'll do something here later...
                UIApplication.shared.setStatusBarHidden(true, with: .fade)
                self.toggleCancelStartButtons(flag: 0)

            })
        }
    }
    
    func handleCancel(flag: Int){
        
        if flag == 0{
            //INITIAL CANCEL, REMOVE MEME EDITOR VIEW
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.alpha = 0
                if let window = UIApplication.shared.keyWindow {
                    self.view.frame = CGRect(x: 0, y: window.frame.height,
                                         width: self.view.frame.width, height: self.view.frame.height)
                }
            }) { (completed: Bool) in }
            
        }else if flag == 1{
            unsubsribeToKeyboardNotification()
            // animated out of the meme editing
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    //animate out the top and bottom TextViews
                    self.topText.frame.origin.y -= self.topText.frame.height
                    self.bottomText.frame.origin.y -= self.topText.frame.height + (1.5 * self.topText.frame.height)
                    
                    self.toggleCancelClearEditButtons(flag: 1)
                    

            }) { (completed: Bool) in
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

                        self.topText.removeFromSuperview()
                        self.bottomText.removeFromSuperview()
                        
                        self.view.frame = CGRect(x: 0, y: 0,
                                                 width: self.view.frame.width, height: self.view.frame.height-self.heightOffset)
                    
                }) { (completed: Bool) in
                    UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        
                        self.toggleCancelStartButtons(flag: 0)
                    }) { (completed: Bool) in }
                }
            }
        }
    }
    
    func handleEdit(){
        //calculate UITextView frames to start off the screen and add them to subview
        topText.frame = CGRect(x: 0, y: 0 - ((2*imageView.frame.height)/5), width: imageView.frame.width, height: ((2*imageView.frame.height)/5))
        bottomText.frame = CGRect(x: 0, y: 0 - ((2*imageView.frame.height)/5), width: imageView.frame.width, height: ((2*imageView.frame.height)/5))
        topText.contentSize.height = topText.frame.height
        topText.contentSize.width = topText.frame.width
        
        bottomText.contentSize.height = topText.frame.height
        bottomText.contentSize.width = bottomText.frame.width
        self.view.addSubview(topText)
        self.view.addSubview(bottomText)
        
        subscribeToKeyboardNotification()
        // 1st animation starts here, rolling the inital buttons off screen
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
                        self.toggleCancelStartButtons(flag: 1)

        }) { (completed: Bool) in
            // 2nd animation, shift view upwards so the image aligns with the top 
            //      of the screen
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                if let window = UIApplication.shared.keyWindow {
                    
                    self.view.frame = CGRect(x: 0, y: -(self.heightOffset),
                                             width: self.view.frame.width, height: self.view.frame.height+self.heightOffset)
                }
                
            }) { (completed: Bool) in
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    // 3rd animation, scroll TextViews down to alight with the 
                    //         image that is now aligned with the top of the screen
                    
                    self.topText.frame.origin.y += self.heightOffset + self.topText.frame.height
                    self.bottomText.frame.origin.y += self.heightOffset + self.topText.frame.height + (1.5 * self.topText.frame.height)
                    self.toggleCancelClearEditButtons(flag: 0)
                }) { (completed: Bool) in
                
                
                }
            }
        }
    }
    
    func handleClear(){
        if self.topText.text != "TOP" || self.bottomText.text != "BOTTOM"{
            self.topText.text = "TOP"
            self.bottomText.text = "BOTTOM"
        }
    }
    
    func handleSave(){
        memify(img: self.originalImage!, textView1: self.topText, textView2: self.bottomText)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        sSaveButton.isUserInteractionEnabled = isMemed()
        configureTextViews([topText, bottomText])
    }
}


extension MemeEditLauncher {
    func isMemed() -> Bool{
        if topText.text != "TOP" && bottomText.text != "BOTTOM"{
            if (topText.text?.characters.count)! > 0 && (bottomText.text?.characters.count)! > 0{
                return true
            }
        }
        return false
    }
    
    /* Pass an array of text fields and set the default text attributes for each */
    func configureTextViews(_ textViews: [UITextView?]){
        for textView in textViews{
            textView?.delegate = self
            //textView?.typingAttributes = memeFont
            textView?.textAlignment = .center
        }
    }
    
    func resizeFont( str:String, fontSize: CGFloat) -> NSAttributedString{
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: fontSize)!,
            NSStrokeWidthAttributeName : -4.0
    ] as [String : Any]
        let newAttr = NSAttributedString(string: str, attributes: memeTextAttributes)
        
        return newAttr
    }
    
    func resizeTyping(fontSize: CGFloat) -> [String:Any]{
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: fontSize)!,
            NSStrokeWidthAttributeName : -4.0
            ] as [String : Any]
        
        return memeTextAttributes
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        selectedTextView = textView
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == topText && topText.text == "TOP"{
            topText.text = ""
        }else if textView == bottomText && bottomText.text == "BOTTOM"{
            bottomText.text = ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.contentSize.height < textView.frame.size.height && currentFontSize < 40{
            currentFontSize += 1
            textView.attributedText = resizeFont(str: textView.text,fontSize: currentFontSize)
            textView.typingAttributes = resizeTyping(fontSize: currentFontSize)
            //print("CurrentFontSize resized as ", currentFontSize)
        }else if textView.contentSize.height > textView.frame.size.height && currentFontSize > 20{
            currentFontSize -= 1
            textView.attributedText = resizeFont(str: textView.text,fontSize: currentFontSize)
            textView.typingAttributes = resizeTyping(fontSize: currentFontSize)
            //print("CurrentFontSize resized as ", currentFontSize)
            //print("Character count ",textView.text.characters.count )
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return true
        }else{
            
            let currentCharacterCount = textView.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            
            let newLength = currentCharacterCount + text.characters.count - range.length
            return newLength <= 120
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView == topText && topText.text == ""{
            topText.text = "TOP"
        }else if textView == bottomText && bottomText.text == ""{
            bottomText.text = "BOTTOM"
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        selectedTextView = nil
        configureTextViews([textView])
        
        /* Enable save button if fields are filled and resign first responder */
        sSaveButton.isUserInteractionEnabled = isMemed()
        
        textView.resignFirstResponder()
    }
    
    /* Suscribe the view controller to the UIKeyboardWillShowNotification */
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditLauncher.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditLauncher.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /* Unsubscribe the view controller to the UIKeyboardWillShowNotification */
    func unsubsribeToKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
    func keyboardWillShow(_ notification: Notification) {
        let keyboardHeight = getKeyboardHeight(notification)
        let keyWindow = UIApplication.shared.keyWindow
        /* slide the view up when keyboard appears, using notifications */
        //if selectedTextView == bottomText && view.frame.origin.y == 0.0 {
        //if the current textView's bottom (its y origin + its height) is less
        //  than the y origin of the keyboard (height of the screen - height 
        //  of the keyboard), then the view needs to be shifted up
        //    The shift needs to be the top of the current textView aligning with
        //    the top of the keyWindow ( textView's y origin )
        //print("keyboard/offset", keyboardHeight, heightOffset)
        //print((selectedTextView?.frame.origin.y)!+(selectedTextView?.frame.height)!, (keyWindow?.frame.height)!-keyboardHeight)
        if ((selectedTextView?.frame.origin.y)!+(selectedTextView?.frame.size.height)!-heightOffset) > (keyWindow?.frame.size.height)!-keyboardHeight{
            view.frame.size.height += ((keyWindow?.frame.size.height)!-keyboardHeight)-((keyWindow?.frame.size.height)!-(selectedTextView?.frame.origin.y)!-heightOffset)
            view.frame.origin.y -= (selectedTextView?.frame.origin.y)!
            
            sSaveButton.isUserInteractionEnabled = false
        }
    }
    
    /* Reset view origin when keyboard hides */
    func keyboardWillHide(_ notification: Notification) {
        if view.frame.origin.y+heightOffset < 0{
            let keyboardHeight = getKeyboardHeight(notification)
            let keyWindow = UIApplication.shared.keyWindow
            view.frame.size.height -= ((keyWindow?.frame.size.height)!-keyboardHeight)-((keyWindow?.frame.size.height)!-(selectedTextView?.frame.origin.y)!-heightOffset)
            view.frame.origin.y += (selectedTextView?.frame.origin.y)!
            sSaveButton.isUserInteractionEnabled = false
        }
    }
    
    /* Get the height of the keyboard from the user info dictionary */
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func memify(img: UIImage, textView1: UITextView, textView2: UITextView){
        let originalImg = img
        //print("Original Image size/width/height ", originalImg.size, originalImg.size.width, originalImg.size.height)
        UIGraphicsBeginImageContext(originalImg.size)
        originalImg.draw(in: CGRect(origin: .zero, size: originalImg.size))
        
        let context = UIGraphicsGetCurrentContext()
        if context == nil{
            print("memify failed, nil context")
        }else{
            print("memify has a context...")
            textView1.layer.render(in: context!)
            textView2.layer.render(in: context!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        }
    }
    
}

