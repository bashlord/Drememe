//
//  PinCell.swift
//  Rendezvous2
//
//  Created by John Jin Woong Kim on 2/12/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import AVFoundation
import UIKit

class PinCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //var photos = Photo.allPhotos()
    let cellId = "AnnotatedPhotoCell"
    var pageIndex = 0
    var widthOffset = -80
    var numberOfPages = 11
    //var layouts = Array(repeating: PinterestLayout(), count: 11)
    var layouts = [PinterestLayout]()
    var mainController: MainController? {
        didSet {
            for i in 0...10{
                let l = PinterestLayout()
                l.page = i
                layouts.append(l)
            }
            
            pageIndex = 0
            //print("photocount ", mainController?.photos.count)
            //print("num of layouts", layouts.count)
            for lay in layouts {
                //print("pre page/cacheSize ", lay.page, lay.cacheSize())
                self.collectionView.collectionViewLayout = lay
                (self.collectionView.collectionViewLayout as! PinterestLayout).delegate = self
                //pageIndex -= 1
                self.collectionView.reloadData()
                //print("post page/cacheSize ", lay.page, lay.cacheSize())
            }
            //print("PinCell:: does it prepare here?")
            pageIndex = 0
        }
    }
    
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
        b.pinCell = self
        b.setFlag(flag: 1)
        return b
    }()
    
    lazy var leftButton: ButtonLauncher = {
        let b = ButtonLauncher()
        b.pinCell = self
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

        
        let keyWindow = UIApplication.shared.keyWindow
        let keyFrame = keyWindow?.frame
        
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

            self.collectionView.collectionViewLayout = layouts[pageIndex]
            self.collectionView.reloadData()
            
            if pageIndex == 0{
                toggleLButton(flag: 1)
            }else if pageIndex == numberOfPages-2{
                toggleRButton(flag: 0)
            }
        }else if flag == 1 && pageIndex < numberOfPages-1{
            pageIndex += 1

            self.collectionView.collectionViewLayout = layouts[pageIndex]
            self.collectionView.reloadData()

            (self.collectionView.collectionViewLayout as! PinterestLayout).delegate = self
            print("page/cache size " , (self.collectionView.collectionViewLayout as! PinterestLayout).page, (self.collectionView.collectionViewLayout as! PinterestLayout).cacheSize())
            if pageIndex == numberOfPages-1{
                toggleRButton(flag: 1)
            }else if pageIndex == 1{
                print("left button toggle in should happen")
                toggleLButton(flag: 0)
            }
            //self.collectionView.reloadData()
        }
        print("current page/left button x/right button x ", pageIndex, leftButton.frame.origin.x, rightButton.frame.origin.x)
    }
    
    override func setupViews() {
        super.setupViews()
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        collectionView.register(AnnotatedPhotoCell.self, forCellWithReuseIdentifier: cellId)
        print("PinCell:: setupViews()")
        self.setupLRButtons()

        //collectionView.register(AnnotatedPhotoCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 288 default photos total
        // 24 images by 12?
        if mainController != nil{
            return 24
        }else{
            return 0
        }
        //return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var offsetIndexPath = indexPath
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath) as! AnnotatedPhotoCell
        //print("Post IndexPath cellForItemAt: ", indexPath.item, indexPath.section, indexPath.row)
        cell.photo = mainController?.photos[indexPath.item+(pageIndex*24)]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item selected at " ,(pageIndex*24)+indexPath.item)
        let memeLauncher = MemeEditLauncher()
        memeLauncher.image = mainController?.photos[(pageIndex*24)+indexPath.item].image
        memeLauncher.path = mainController?.photos[(pageIndex*24)+indexPath.item].path
        memeLauncher.params = (mainController?.photos[(pageIndex*24)+indexPath.item].params)!
        let style = mainController?.photos[(pageIndex*24)+indexPath.item].style
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
        memeLauncher.index = (pageIndex*24)+indexPath.item
        memeLauncher.pinCell = self
        memeLauncher.isFav = mainController?.photos[(pageIndex*24)+indexPath.item].isFaved()
        memeLauncher.expandMemeView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func toggleFavorite(index:Int){
        mainController?.photos[index].toggleFav()
    }
}

extension PinCell : PinterestLayoutDelegate {
    // 1. Returns the photo height
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth width:CGFloat) -> CGFloat {
        print("PinCell:: beginning heightForPhotoAtIndexPath for ", indexPath.item)
        let photo = mainController?.photos[(pageIndex*24)+indexPath.item]
        let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect  = AVMakeRect(aspectRatio: (photo?.image.size)!, insideRect: boundingRect)
        print("PinCell:: photo height calculated and returned ", rect.size.height)
        return rect.size.height
    }
    
    // 2. Returns the annotation size based on the text
    func collectionView(_ collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let annotationPadding = CGFloat(4)
        let annotationHeaderHeight = CGFloat(17)
        
        let photo = mainController?.photos[(pageIndex*24)+indexPath.item]
        let font = UIFont(name: "AvenirNext-Regular", size: 10)!
        let commentHeight = photo?.heightForComment(font, width: width)
        let height = annotationPadding + annotationHeaderHeight + commentHeight! + annotationPadding
        return height
    }
}
