//
//  MemeLauncher.swift
//  Rendezvous2
//
//  Created by John Jin Woong Kim on 2/14/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import UIKit
import AVFoundation

class MemeLauncher: NSObject {
    var view = UIView()
    var imageView = UIImageView()
    var path:String?
    var createdCollectionView: CreatedCollectionView?
    var height: CGFloat = 0.0
    var image: UIImage? {
        didSet {
            if let image = image{
                self.image = image
            }
        }
    }
    
    lazy var cancelButton: ButtonLauncher = {
        let b = ButtonLauncher()
        //b.homeController = self
        b.memeLauncher = self
        b.setFlag(flag: 2)
        return b
    }()
    
    fileprivate func setupLRButtons(view: UIView){
        cancelButton.collectionView.layer.cornerRadius = 40
        view.addSubview(cancelButton)
        view.addConstraintsWithFormat("H:|-16-[v0]-16-|", views: cancelButton)
        view.addConstraintsWithFormat("V:[v0(80)]-16-|", views: cancelButton)
    }
    
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
            height = keyWindow.frame.height-112

            let memeFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height-112)
            imageView.frame = memeFrame
            
            //resize any image to be able to fit the memeFrame with respect to the 
            // image's ratio, then set the image to the memeView's image
            //let fittedImage = imageWithImage(image: self.image!, scaledToSize: CGSize(width: memeFrame.width, height: memeFrame.height))
            imageView.image = self.image
            
            
            //add the imageview to memeview with the vertical constraint 175px
            // from the top, then add the memeview to the view
            view.addSubview(imageView)
            view.addConstraintsWithFormat("V:|[v0]", views: imageView)
            
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
    
    func handleEdit(){
    
    }
}


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
