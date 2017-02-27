//
//  FavoritesCollectionView.swift
//  Rendezvous2
//
//  Created by John Jin Woong Kim on 2/12/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import AVFoundation
import UIKit

class FavoritesCollectionView: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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
        b.favoritesCollectionView = self
        b.setFlag(flag: 1)
        return b
    }()
    
    lazy var leftButton: ButtonLauncher = {
        let b = ButtonLauncher()
        b.favoritesCollectionView = self
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
        addSubview(rightButton)
        addConstraintsWithFormat("H:[v0(80)]-16-|", views: rightButton)
        addConstraintsWithFormat("V:[v0(80)]-16-|", views: rightButton)
        
        leftButton.collectionView.layer.cornerRadius = 40
        addSubview(leftButton)
        addConstraintsWithFormat("H:|-(\(widthOffset))-[v0(80)]", views: leftButton)
        addConstraintsWithFormat("V:[v0(80)]-16-|", views: leftButton)
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
        
        //collectionView.register(AnnotatedPhotoCell.self, forCellWithReuseIdentifier: cellId)
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
            if (mainController?.favPhotos.count)! < 24 {
                return (mainController?.favPhotos.count)!
            }else{
                return 24
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var offsetIndexPath = indexPath
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath) as! AnnotatedPhotoCell
        //print("Post IndexPath cellForItemAt: ", indexPath.item, indexPath.section, indexPath.row)
        cell.photo = mainController?.photos[(mainController?.favPhotos[ (pageIndex*24)+indexPath.item])!]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item selected at " ,(pageIndex*24)+indexPath.item)
        let memeLauncher = MemeEditLauncher()
        let index = (mainController?.favPhotos[ (pageIndex*24)+indexPath.item])!
        memeLauncher.image = mainController?.photos[index].image
        memeLauncher.path = mainController?.photos[index].path
        memeLauncher.params = (mainController?.photos[index].params)!
        let style = mainController?.photos[index].style
        if style != "Default"{
            if style == "One-Panel"{
                memeLauncher.styleType = 1
            }else if style == "Two-Panel"{
                memeLauncher.styleType = 2
            }else if style == "Three-Panel"{
                memeLauncher.styleType = 3
            }else if style == "Four-Panel"{
                memeLauncher.styleType = 4
            }else if style == "Custom"{
                memeLauncher.styleType = 5
            }
        }
        memeLauncher.expandMemeView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension FavoritesCollectionView : PinterestLayoutDelegate {
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
