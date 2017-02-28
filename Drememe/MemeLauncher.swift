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
    
    lazy var imageView: UIImageView = {
        let keyWindow = UIApplication.shared.keyWindow
        let iv = UIImageView()
        return iv
    }()
    
    lazy var cancelButton: ButtonLauncher = {
        let b = ButtonLauncher()
        //b.homeController = self
        b.memeLauncher = self
        b.setFlag(flag: 2)
        return b
    }()
    
    lazy var deleteButton: ButtonLauncher = {
        let b = ButtonLauncher()
        b.memeLauncher = self
        b.setFlag(flag: 10)
        return b
    }()
    
    fileprivate func setupLRButtons(view: UIView){
        let keyFrame = UIApplication.shared.keyWindow?.frame
        self.cancelButton.collectionView.layer.cornerRadius = 40
        self.cancelButton.frame = CGRect(x: 0 - 80, y: (keyFrame!.height)-96, width: 80, height: 80)
        self.view.addSubview(self.cancelButton)
        
        self.deleteButton.collectionView.layer.cornerRadius = 40
        self.deleteButton.frame = CGRect(x: keyFrame!.width + 80, y: (keyFrame!.height)-96, width: 80, height: 80)
        self.view.addSubview(self.deleteButton)
    }
    
    func toggleCancelStartButtons(flag: Int){
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
            if flag == 0{//toggle into view
                self.cancelButton.frame.origin.x += 96
                self.deleteButton.frame.origin.x -= 176
            }else{//toggle outside of the view
                self.cancelButton.frame.origin.x -= 96
                self.deleteButton.frame.origin.x += 176

            }
        }) { (completed: Bool) in }
    }
    
    func expandMemeView(){
        if let keyWindow = UIApplication.shared.keyWindow {
            view = UIView()
            view.backgroundColor = UIColor.black
            view.frame = CGRect(x: 0, y: keyWindow.frame.height-10, width: keyWindow.frame.width, height: 10)
            height = keyWindow.frame.height-112
            let memeFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height-112)
            
            imageView.frame = memeFrame
            imageView.contentMode = .scaleAspectFit
            imageView.image = self.image
            
            view.addSubview(imageView)
            //view.addConstraintsWithFormat("V:|[v0]", views: imageView)
            setupLRButtons(view: self.view)
            keyWindow.addSubview(view)
            let tempFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                //Main Animation
                self.view.frame = tempFrame
            }, completion: { (completedAnimation) in
                //completion animation
                self.toggleCancelStartButtons(flag: 0)
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
    
    func handleDelete(){
        // need to remove the image from the $CURR_DIR/Created/ folder as well as from Created.plist
        let res = createdCollectionView?.mainController?.createdPhotos.removeCreated(path: path!)
        createdCollectionView?.collectionView.reloadData()
        if res == true{
            handleCancel()
        }
    }
}

