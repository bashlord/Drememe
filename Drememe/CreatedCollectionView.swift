//
//  CreatedCollectionView.swift
//  Drememe
//
//  Created by John Jin Woong Kim on 2/24/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CreatedCollectionView: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "AnnotatedPhotoCell"
    var mainController: MainController?
    // 12 pages total for default
    var pageIndex = 0
    var widthOffset = -80
    var numberOfPages = 1
    
    lazy var collectionView: UICollectionView = {
        let layout = PinterestLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        
        return cv
    }()
    
    lazy var rightButton: ButtonLauncher = {
        let b = ButtonLauncher()
        b.createdCollectionView = self
        b.setFlag(flag: 1)
        return b
    }()
    
    lazy var leftButton: ButtonLauncher = {
        let b = ButtonLauncher()
        b.createdCollectionView = self
        b.setFlag(flag: 0)
        return b
    }()
    
    func toggleRButton(flag: Int){
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            if( flag == 1){// 1 = toggle out
                self.rightButton.frame.origin.x += 96
            }else{// 0 = toggle in
                self.rightButton.frame.origin.x -= 96
            }
        }) { (completed: Bool) in}
    }
    
    func toggleLButton(flag: Int){
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            if( flag == 1){// 1 = toggle out
                self.leftButton.frame.origin.x -= 96
            }else{// 0 = toggle in
                self.leftButton.frame.origin.x += 96
            }
        }) { (completed: Bool) in}
    }
    
    func setupLRButtons(){
        rightButton.collectionView.layer.cornerRadius = 40
        rightButton.frame = CGRect(x: self.frame.width - 96, y: self.frame.height - 96, width: 80, height: 80)
        addSubview(rightButton)
        
        leftButton.collectionView.layer.cornerRadius = 40
        leftButton.frame = CGRect(x: 0 - 80, y: self.frame.height - 96, width: 80, height: 80)
        addSubview(leftButton)
    }
    
    func handlePager(flag: Int){
        if flag == 0 && pageIndex > 0{
            pageIndex -= 1
            self.collectionView.reloadData()
            if pageIndex == 0{
                toggleLButton(flag: 1)
            }else if pageIndex == numberOfPages-2{
                toggleRButton(flag: 0)
            }
        }else if flag == 1 && pageIndex < numberOfPages-1{
            pageIndex += 1
            self.collectionView.reloadData()
            if pageIndex == numberOfPages-1{
                toggleRButton(flag: 1)
            }else if pageIndex == 1{
                toggleLButton(flag: 0)
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        collectionView.register(AnnotatedPhotoCell.self, forCellWithReuseIdentifier: cellId)

        if self.collectionView.collectionViewLayout is PinterestLayout {
            self.collectionView.collectionViewLayout = PinterestLayout()
            (self.collectionView.collectionViewLayout as! PinterestLayout).delegate = self
            print("does it prepare here?")
            self.setupLRButtons()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 288 default mainController?.photos total
        // 24 images by 12?
        if mainController == nil{
            return 0
        }else{
            if (mainController?.createdPhotos.getCount())! < 24 {
                return (mainController?.createdPhotos.getCount())!
            }else{
                return 24
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //var offsetIndexPath = indexPath
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath) as! AnnotatedPhotoCell
        cell.image = mainController?.createdPhotos.getAnnotatedImage(index: indexPath.item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item selected at " ,(pageIndex*24)+indexPath.item)
        let memeLauncher = MemeLauncher()
        memeLauncher.image = mainController?.createdPhotos.getOriginalImage(index: indexPath.item)
        //memeLauncher.path = mainController?.photos[index].path
        memeLauncher.createdCollectionView = self
        memeLauncher.expandMemeView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension CreatedCollectionView : PinterestLayoutDelegate {
    // 1. Returns the photo height
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth width:CGFloat) -> CGFloat {
        let index = mainController?.favPhotos[(pageIndex*24)+indexPath.item]
        let photo = mainController?.photos[index!]
        let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect  = AVMakeRect(aspectRatio: (photo?.image.size)!, insideRect: boundingRect)
        return rect.size.height
    }
    
    // 2. Returns the annotation size based on the text
    func collectionView(_ collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let annotationPadding = CGFloat(4)
        let annotationHeaderHeight = CGFloat(17)
        let index = mainController?.favPhotos[(pageIndex*24)+indexPath.item]
        let photo = mainController?.photos[index!]
        let font = UIFont(name: "AvenirNext-Regular", size: 10)!
        let commentHeight = photo?.heightForComment(font, width: width)
        let height = annotationPadding + annotationHeaderHeight + commentHeight! + annotationPadding
        return height
    }
}
