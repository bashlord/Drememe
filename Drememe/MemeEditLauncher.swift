//
//  MemeLauncher.swift
//  Rendezvous2
//
//  Created by John Jin Woong Kim on 2/14/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import UIKit
import AVFoundation

func imageWithImage(image:UIImage, scaledToSize size:CGSize ) -> UIImage {
    let hasAlpha = false
    let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
    
    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
    image.draw(in: CGRect(origin: .zero, size: size))
    
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage!
}

let memeFont = [
    NSStrokeColorAttributeName: UIColor.black,
    NSForegroundColorAttributeName: UIColor.white,
    NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40.0)!,
    NSStrokeWidthAttributeName : -4.0
] as [String : Any]

class MemeEditLauncherView: UIView{
    let toolsView = UIView()
    var launcher: MemeEditLauncher?
    
    func addToolsView(view: UIView){
        view.addSubview(toolsView)
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        print("frame parameters:: ", frame.width, frame.height)
        toolsView.frame =  CGRect(x: 0, y: frame.height/2, width: frame.width, height: frame.height/2)
        toolsView.backgroundColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MemeEditLauncher: NSObject {
    var view = MemeEditLauncherView()
    
    var imageView = UIImageView()
    var picWidth: CGFloat = 0.0
    var picHeight: CGFloat = 0.0
    //the editiing tools view UI
    //var memeEditLauncherView: MemeLauncherView?
    var path:String?
    
    var tempCancelB: CGRect?
    var tempStartB: CGRect?
    
    var image: UIImage? {
        didSet {
            if let image = image{
                self.image = image
            }
        }
    }
    
    lazy var topText: UITextField = {
        let textField = UITextField()
        textField.defaultTextAttributes = memeFont
        textField.textAlignment = .center
        textField.text = "Top"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return textField
    }()
    
    lazy var bottomText: UITextField = {
        let textField = UITextField()
        textField.defaultTextAttributes = memeFont
        textField.textAlignment = .center
        textField.text = "Bottom"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.2)
        return textField
    }()
    
    lazy var cancelButton: ButtonLauncher = {
        let b = ButtonLauncher()
        //b.homeController = self
        b.memeEditLauncher = self
        b.setFlag(flag: 2)
        return b
    }()
    
    lazy var startButton: ButtonLauncher = {
        let b = ButtonLauncher()
        //b.homeController = self
        b.memeEditLauncher = self
        b.setFlag(flag: 3)
        return b
    }()
    
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
    
    fileprivate func setupMemeView(view: UIView, frame: CGRect, img: UIImage){
        imageView.frame = frame
        imageView.image = img
        self.view.addSubview(imageView)
        self.view.addConstraintsWithFormat("V:|-175-[v0]", views: imageView)
        
        self.startButton.collectionView.layer.cornerRadius = 40
        self.startButton.frame = CGRect(x: frame.width + 80, y: (frame.height*2)-96, width: 80, height: 80)
        self.view.addSubview(self.startButton)
        //self.view.addConstraintsWithFormat("H:[v0(80)]-16-|", views: startButton)
        //self.view.addConstraintsWithFormat("V:[v0(80)]-16-|", views: startButton)
        
        self.cancelButton.collectionView.layer.cornerRadius = 40
        self.cancelButton.frame = CGRect(x: 0 - 80, y: (frame.height*2)-96, width: 80, height: 80)
        self.view.addSubview(self.cancelButton)
        //self.view.addConstraintsWithFormat("H:|-16-[v0(80)]", views: cancelButton)
        //self.view.addConstraintsWithFormat("V:[v0(80)]-16-|", views: cancelButton)
    }
    
    func expandMemeView(){
        if let keyWindow = UIApplication.shared.keyWindow {
            view.launcher = self
            view.backgroundColor = UIColor.black
            view.frame = CGRect(x: 0, y: keyWindow.frame.height-10, width: keyWindow.frame.width, height: 10)
            
            //set memeView's frame, which will be holding the image to half the
            // height of the window frame height and the same width as the window
            let height = keyWindow.frame.height/2
            let memeFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            
            picWidth = keyWindow.frame.width
            picHeight = height
            
            
            //resize any image to be able to fit the memeFrame with respect to the
            // image's ratio, then set the image to the memeView's image
            let fittedImage = imageWithImage(image: self.image!, scaledToSize: CGSize(width: memeFrame.width, height: memeFrame.height))
            
            setupMemeView(view: self.view, frame: memeFrame, img: fittedImage)
            //setupLRButtons(view: self.view)
            keyWindow.addSubview(view)
            
            let tempFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.frame = tempFrame
            }, completion: { (completedAnimation) in
                //maybe we'll do something here later...
                UIApplication.shared.setStatusBarHidden(true, with: .fade)
                self.toggleCancelStartButtons(flag: 0)
                self.tempStartB = self.startButton.frame
                self.tempCancelB = self.cancelButton.frame
                
            })
        }
    }
    
    func handleCancel(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        
            self.view.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self.view.frame = CGRect(x: 0, y: window.frame.height,
                                         width: self.view.frame.width, height: self.view.frame.height)
            }
            
        }) { (completed: Bool) in }
    }
    
    func handleEdit(){
        topText.frame = CGRect(x: 0, y: 0 - ((2*picHeight)/5), width: picWidth, height: ((2*picHeight)/5))
        bottomText.frame = CGRect(x: 0, y: 0 - ((2*picHeight)/5), width: picWidth, height: ((2*picHeight)/5))
        self.view.addSubview(topText)
        self.view.addSubview(bottomText)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            //self.view.alpha = 0
            self.toggleCancelStartButtons(flag: 1)

        }) { (completed: Bool) in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                if let window = UIApplication.shared.keyWindow {
                    
                    self.view.frame = CGRect(x: 0, y: -175,
                                             width: self.view.frame.width, height: self.view.frame.height)
                    
                    
                }
                
            }) { (completed: Bool) in
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.topText.frame.origin.y += 175 + self.topText.frame.height
                    self.bottomText.frame.origin.y += 175 + self.topText.frame.height + (1.5 * self.topText.frame.height)
                    
                
                }) { (completed: Bool) in }
            
            }
        }
    }
}

/*
 merged setting up of views into 1 function
 
 fileprivate func setupLRButtons(view: UIView){
 startButton.collectionView.layer.cornerRadius = 40
 view.addSubview(startButton)
 view.addConstraintsWithFormat("H:[v0(80)]-16-|", views: startButton)
 view.addConstraintsWithFormat("V:[v0(80)]-16-|", views: startButton)
 
 cancelButton.collectionView.layer.cornerRadius = 40
 view.addSubview(cancelButton)
 view.addConstraintsWithFormat("H:|-16-[v0(80)]", views: cancelButton)
 view.addConstraintsWithFormat("V:[v0(80)]-16-|", views: cancelButton)
 }
 */


/*
 Original expand/cancel functions, set aside in order to customize an edit option
 Will probably use it for the saved collectionView
 
 func expandMemeView(){
 if let keyWindow = UIApplication.shared.keyWindow {
 //init default view, change frame size to start off as 10 px tall and window.width wide
 //and the top left corner of view starting off at coords 0 : window.height-10
 view = UIView()
 //set view to
 view.backgroundColor = UIColor.black
 view.frame = CGRect(x: 0, y: keyWindow.frame.height-10, width: keyWindow.frame.width, height: 10)
 
 //set memeView's frame, which will be holding the image to half the
 // height of the window frame height and the same width as the window
 let height = keyWindow.frame.height/2
 let memeFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
 imageView.frame = memeFrame
 
 //resize any image to be able to fit the memeFrame with respect to the
 // image's ratio, then set the image to the memeView's image
 let fittedImage = imageWithImage(image: self.image!, scaledToSize: CGSize(width: memeFrame.width, height: memeFrame.height))
 imageView.image = fittedImage
 
 
 //add the imageview to memeview with the vertical constraint 175px
 // from the top, then add the memeview to the view
 view.addSubview(imageView)
 view.addConstraintsWithFormat("V:|-175-[v0]", views: imageView)
 
 setupLRButtons(view: self.view)
 keyWindow.addSubview(view)
 
 let tempFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)
 UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
 
 //view.frame = keyWindow.frame
 self.view.frame = tempFrame
 
 }, completion: { (completedAnimation) in
 //maybe we'll do something here later...
 UIApplication.shared.setStatusBarHidden(true, with: .fade)
 })
 
 }
 }
 
 func handleCancel(){
 UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
 self.view.alpha = 0
 if let window = UIApplication.shared.keyWindow {
 self.view.frame = CGRect(x: 0, y: window.frame.height,
 width: self.view.frame.width, height: self.view.frame.height)
 }
 
 }) { (completed: Bool) in }
 }
 
 
 */
