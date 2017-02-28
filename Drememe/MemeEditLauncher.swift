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
    var currentFontSize: CGFloat = 30.0
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

    var params = [Param]()
    var styleType: Int = 0
    //used for custom textViews that need to have their frames translated
    var scalar_h: CGFloat = 0.0
    var scalar_w: CGFloat = 0.0
    var customTextViews = [UITextView]()
    //not sure if i need this
    var selectedTextView: UITextView?
    var index = 0
    
    var pinCell: PinCell?
    var favoriteCollectionView: FavoritesCollectionView?
    
    var image: UIImage? {
        didSet {
            if let image = image{
                self.image = image
            }
        }
    }
    var favButton: ButtonLauncher?
    var isFav: Bool?{
        didSet{
            if isFav!{
                favButton = ButtonLauncher()
                favButton?.memeEditLauncher = self
                favButton?.setFlag(flag: 8)
            }else{
                favButton = ButtonLauncher()
                favButton?.memeEditLauncher = self
                favButton?.setFlag(flag: 7)
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
        textView.text = ""
        textView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        textView.returnKeyType = .done
        return textView
    }()
    
    lazy var bottomText: UITextView = {
        let textView = UITextView()
        textView.typingAttributes = memeFont
        textView.textAlignment = .center
        textView.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        textView.text = ""
        textView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        textView.returnKeyType = .done
        return textView
    }()
    
    var thirdTextView: UITextView!
    var fourthTextView: UITextView!
    
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
                //self.favButton!.frame.origin.y = self.view.frame.height - 96
                self.favButton!.frame.origin.y -= 96 + self.heightOffset
            }else{//toggle out
                self.cancelButton.frame.origin.x -= 96
                self.startButton.frame.origin.x += 176
                //self.favButton!.frame.origin.y = self.view.frame.height
                self.favButton!.frame.origin.y += 96 + self.heightOffset
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
        
        self.favButton?.collectionView.layer.cornerRadius = 40
        self.favButton?.frame = CGRect(x: (keyFrame.width/2) - 40, y: (keyFrame.height)+heightOffset, width: 80, height: 80)
        self.view.addSubview(self.favButton!)
        
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
                //print(path, "surpasses height limit ratio")
            }else if (height! < heightLimit!/2){
                height = heightLimit!/2
                //print(path, "is short AF")
            }
            let memeFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height!)
            
            if styleType == 5 {
                scalar_h = height!/(originalImage?.size.height)!
                scalar_w = keyWindow.frame.width/(originalImage?.size.width)!
                for p in params {
                    p.scalar_h = scalar_h
                    p.scalar_w = scalar_w
                }
            }
            
            //resize any image to be able to fit the memeFrame with respect to the
            // image's ratio, then set the image to the memeView's image
            let fittedImage = imageWithImage(image: self.image!, scaledToSize: CGSize(width: memeFrame.width, height: memeFrame.height))
            //init the view, adding the image, cancel, and edit buttons to subview
            heightOffset = (heightLimit!/2)-(memeFrame.height/2)
            setupMemeView(view: self.view, frame: memeFrame, img: fittedImage, keyFrame: keyWindow.frame)
            keyWindow.addSubview(view)
            
            let tempFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.frame = tempFrame
            }, completion: { (completedAnimation) in
                //maybe we'll do something here later...
                UIApplication.shared.setStatusBarHidden(true, with: .fade)
                self.toggleCancelStartButtons(flag: 0)
            })
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////
    ////////////////////// Animations/Handlers /////////////////////////////////
    //////////////////////////////////////////////////////////////////
    
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
                //self.defaultTextViewAnimate(phase: 2)
                
                if self.styleType == 2{
                    self.twoPanelTextViewAnimation(phase: 2)
                }else if self.styleType == 3{
                    self.threePanelTextViewAnimation(phase: 2)
                }else if self.styleType == 4{
                    self.fourPanelTextViewAnimation(phase: 2)
                }else if self.styleType == 5{
                    self.customTextViewAnimate(phase: 2)
                }else{
                    self.defaultTextViewAnimate(phase: 2)
                }
                
                self.toggleCancelClearEditButtons(flag: 1)
            }) { (completed: Bool) in // enter 1
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    //self.defaultTextViewAnimate(phase: 3)
                    if self.styleType == 2{
                        self.twoPanelTextViewAnimation(phase: 3)
                    }else if self.styleType == 3{
                        self.threePanelTextViewAnimation(phase: 3)
                    }else if self.styleType == 4{
                        self.fourPanelTextViewAnimation(phase: 3)
                    }else if self.styleType == 5{
                        self.customTextViewAnimate(phase: 3)
                    }else{
                        self.defaultTextViewAnimate(phase: 3)
                    }
                    self.view.frame = CGRect(x: 0, y: 0,
                                                 width: self.view.frame.width, height: self.view.frame.height-self.heightOffset)
                    
                }) { (completed: Bool) in //enter 2
                    UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.toggleCancelStartButtons(flag: 0)
                    }) { (completed: Bool) in }
                }// leave 2
            } //  leave 1
        }
    }
    
    func handleEdit(){
        //calculate UITextView frames to start off the screen and add them to subview
        if self.styleType == 2{
            twoPanelTextViewAnimation(phase: 0)
        }else if self.styleType == 3{
            self.threePanelTextViewAnimation(phase: 0)
        }else if self.styleType == 4{
            self.fourPanelTextViewAnimation(phase: 0)
        }else if self.styleType == 5{
            self.customTextViewAnimate(phase: 0)
        }else{
            defaultTextViewAnimate(phase: 0)
        }
        
        subscribeToKeyboardNotification()
        // BEGIN Animations >>>>>
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            // 1st animation starts here, rolling the inital buttons off screen
            self.toggleCancelStartButtons(flag: 1)
        }) { (completed: Bool) in // 1
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                // 2nd animation, shift view upwards so the image aligns with the top
                //      of the screen
                if let window = UIApplication.shared.keyWindow {
                    self.view.frame = CGRect(x: 0, y: -(self.heightOffset), width: self.view.frame.width, height: self.view.frame.height+self.heightOffset)
                }
            }) { (completed: Bool) in // 2
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    // 3rd animation, scroll TextViews down to alight with the 
                    //         image that is now aligned with the top of the screen
                    //self.defaultTextViewAnimate(phase: 1)
                    if self.styleType == 2{
                        self.twoPanelTextViewAnimation(phase: 1)
                    }else if self.styleType == 3{
                        self.threePanelTextViewAnimation(phase: 1)
                    }else if self.styleType == 4{
                        self.fourPanelTextViewAnimation(phase: 1)
                    }else if self.styleType == 5{
                        self.customTextViewAnimate(phase: 1)
                    }else{
                        self.defaultTextViewAnimate(phase: 1)
                    }
                    
                    self.toggleCancelClearEditButtons(flag: 0)
                }) { (completed: Bool) in //3
                        // End Animations <<<<<
                    }// 3
            } // 2
        }// 1
    }
    
    func handleClear(){
        //if self.topText.text != "TOP" || self.bottomText.text != "BOTTOM"{
        self.topText.text = ""
        self.bottomText.text = ""
        if self.thirdTextView != nil{
            self.thirdTextView.text = ""
        }
        if self.fourthTextView != nil{
            self.fourthTextView.text = ""
        }
        //}
    }
    
    func handleSave(){
        
        if areTextViewsSet(){
            var texts = [String]()
            texts.append(topText.text)
            texts.append(bottomText.text)
            if thirdTextView != nil{
                texts.append(thirdTextView.text)
            }
            if fourthTextView != nil{
                texts.append(fourthTextView.text)
            }
            
            let meme = Memifier.sharedInstance.createImage(orgImage: self.originalImage!, style: self.styleType, params: self.params, texts: texts)
            UIImageWriteToSavedPhotosAlbum(meme, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            if pinCell != nil{
                pinCell?.mainController?.createdPhotos.addNewCreated(image: meme)
            }else if favoriteCollectionView != nil{
                favoriteCollectionView?.mainController?.createdPhotos.addNewCreated(image: meme)
            }
            handleCancel(flag: 1)
            handleCancel(flag: 0)
            
            //memify(img: self.originalImage!, textView1: self.topText, textView2: self.bottomText)
        }else{
            let alertController = UIAlertController(title: "Fill out the Memes", message: "Requires more dank.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
            }
            
            alertController.addAction(okAction)
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func handleFav(flag: Int){
        if flag == 0{// add as favorite
            PlistManager.sharedInstance.addNewItemWithKey( key: String(index), value: index as AnyObject, flag: 0)
            
            if pinCell != nil{
                pinCell?.mainController?.favPhotos.append(index)
                pinCell?.collectionView.reloadData()
            }else if favoriteCollectionView != nil{
                favoriteCollectionView?.mainController?.favPhotos.append(index)
                favoriteCollectionView?.collectionView.reloadData()
            }
        }else{// remove from favorites
            PlistManager.sharedInstance.removeItemForKey(key: String(index), flag: 0)
            if pinCell != nil{
                for x in 0...(pinCell?.mainController?.favPhotos.count)!{
                    if pinCell?.mainController?.favPhotos[x] == index{
                        pinCell?.mainController?.favPhotos.remove(at: x)
                        break
                    }
                }
                pinCell?.collectionView.reloadData()
                //pinCell?.mainController?.favPhotos.append(index)
            }else if favoriteCollectionView != nil{
                for x in 0...(favoriteCollectionView?.mainController?.favPhotos.count)!{
                    if favoriteCollectionView?.mainController?.favPhotos[x] == index{
                        favoriteCollectionView?.mainController?.favPhotos.remove(at: x)
                        break
                    }
                }
                favoriteCollectionView?.collectionView.reloadData()
                //favoriteCollectionView?.mainController?.favPhotos.append(index)
            }
        }
        if pinCell != nil{
            pinCell?.toggleFavorite(index: index)
        }else{
            //need to call toggle in favoriteCollectionView
        }
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
        if topText.text != "" && bottomText.text != ""{
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
        if textView == topText{
            print("topText selected")
        }else if textView == bottomText{
            print("bottomText selected")
        }else{
            print("thirdTextView selected")
        }
        selectedTextView = textView
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //print(textView.font?.fontDescriptor.size)
        /*if textView == topText && topText.text == "TOP"{
            topText.text = ""
        }else if textView == bottomText && bottomText.text == "BOTTOM"{
            bottomText.text = ""
        }*/
        if currentFontSize > textView.frame.size.height{
            currentFontSize = textView.frame.size.height
            textView.attributedText = resizeFont(str: textView.text,fontSize: currentFontSize)
            textView.typingAttributes = resizeTyping(fontSize: currentFontSize)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.contentSize.height < textView.frame.size.height && currentFontSize < 40{
            //while textView.contentSize.height < textView.frame.size.height && currentFontSize < 40{
                currentFontSize += 1
                //textView.attributedText = resizeFont(str: textView.text,fontSize: currentFontSize)
                //textView.typingAttributes = resizeTyping(fontSize: currentFontSize)
                //textView.contentSize.height = textView.frame.size.height
            //}
            //print("CurrentFontSize resized as ", currentFontSize)
        }else if textView.contentSize.height > textView.frame.size.height && currentFontSize > 10{
            
            //while textView.contentSize.height > textView.frame.size.height && currentFontSize > 10{
                currentFontSize -= 1

                //textView.contentSize.height = textView.frame.size.height
            //}
            //currentFontSize -= 1
            //textView.attributedText = resizeFont(str: textView.text,fontSize: currentFontSize)
            //textView.typingAttributes = resizeTyping(fontSize: currentFontSize)
            //print("CurrentFontSize resized as ", currentFontSize)
            //print("Character count ",textView.text.characters.count )
        }
        textView.attributedText = resizeFont(str: textView.text,fontSize: currentFontSize)
        textView.typingAttributes = resizeTyping(fontSize: currentFontSize)
        print(currentFontSize)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return true
        }else{
            
            let currentCharacterCount = textView.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount) || (currentCharacterCount >= 120){
                return false
            }
            
            let newLength = currentCharacterCount + text.characters.count - range.length
            return newLength <= 120
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView == topText && topText.text == ""{
            //topText.text = "TOP"
        }else if textView == bottomText && bottomText.text == ""{
            //bottomText.text = "BOTTOM"
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

    func toggleTextViewUI(flag: Int){
        var b = true
        var str = "true"
        if flag == 0{
            b = false
            str = "false"
        }
        if selectedTextView != bottomText{
            bottomText.isUserInteractionEnabled = b
            print("bottom UI set to ", str)
        }
        if selectedTextView != topText{
            topText.isUserInteractionEnabled = b
            print("top UI set to ", str)
            print(bottomText.isUserInteractionEnabled)
        }
        if thirdTextView != nil && selectedTextView != thirdTextView{
            thirdTextView.isUserInteractionEnabled = b
            print("third UI set to ", str)
        }
        if fourthTextView != nil && selectedTextView != fourthTextView{
            fourthTextView.isUserInteractionEnabled = b
            print("forth UI set to ", str)
        }
    }
    
    
    func keyboardWillShow(_ notification: Notification) {
        let keyboardHeight = getKeyboardHeight(notification)
        let keyWindow = UIApplication.shared.keyWindow
        toggleTextViewUI(flag: 0)
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
        
        toggleTextViewUI(flag: 1)
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
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: originalImg.size))
        imageView.image = originalImg
        topText.backgroundColor = UIColor(white: 0, alpha: 0)
        imageView.addSubview(topText)
        UIGraphicsBeginImageContext(originalImg.size)
        
        
        //originalImg.draw(in: CGRect(origin: .zero, size: originalImg.size))
        //textView1.backgroundColor = UIColor(white: 0, alpha: 0)
        //textView1.layer.draw(in: CGRect(x: 50, y: 50, width: 100, height: 100) as! CGContext)
        let context = UIGraphicsGetCurrentContext()
        
        imageView.layer.render(in: context!)
        
        if context == nil{
            print("memify failed, nil context")
        }else{
            print("memify has a context...")
        
            //textView1.layer.render(in: context!)
            //textView2.layer.render(in: context!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print("Error with saving photo")
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
        } else {
            print("Photo saved")
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        }
    }

}










