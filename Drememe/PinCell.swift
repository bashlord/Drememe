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
    //   Taking out the paging collectionview.  Its getting out of hand
    //var numberOfPages = 5
    //var imagePerPage = 13
    //   Below is the updated values for a trigrid layout
    var numberOfPages = 1
    var imagePerPage = 65
    var memeEditLauncher = MemeEditLauncher()
    
    var layouts = [PinterestLayout]()
    var trilayout = TrigridLayout()
    
    lazy var collectionView: UICollectionView = {
        let layout = TrigridLayout()
        print("PinCell TrigridCollectionView init")
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    var mainController: MainController? {
        didSet {
            if layouts.count == 0{
                self.collectionView.collectionViewLayout = trilayout
                (self.collectionView.collectionViewLayout as! TrigridLayout).delegate = self
                self.collectionView.reloadData()
                
                // older version where there was a right/left pager
                //   and partitioned collectionviews
                
                /*for i in 0...numberOfPages-1{
                    let l = PinterestLayout()
                    l.page = i
                    
                    self.collectionView.collectionViewLayout = l
                    (self.collectionView.collectionViewLayout as! PinterestLayout).delegate = self
                    self.collectionView.reloadData()
                    layouts.append(l)
                    pageIndex+=1
                }
                 
                 pageIndex = 0
                 */
                
                /*for lay in layouts {
                    self.collectionView.collectionViewLayout = lay
                    (self.collectionView.collectionViewLayout as! PinterestLayout).delegate = self
                    self.collectionView.reloadData()
                    pageIndex += 1
                }*/
                
                
                //pageIndex = 0
                //self.collectionView.collectionViewLayout = layouts[0]
                //(self.collectionView.collectionViewLayout as! PinterestLayout).delegate = self
                //self.collectionView.reloadData()

            }
        }
    }
    
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
        rightButton.collectionView.layer.cornerRadius = 40
        rightButton.frame = CGRect(x: self.frame.width - 96, y: self.frame.height - 96, width: 80, height: 80)
        addSubview(rightButton)
        
        leftButton.collectionView.layer.cornerRadius = 40
        leftButton.frame = CGRect(x: 0 - 80, y: self.frame.height - 96, width: 80, height: 80)
        addSubview(leftButton)
    }
    
    func handlePager(flag: Int){
        if flag == 0 && pageIndex > 0{
            // left button pressed while page index > 0
            pageIndex -= 1
            self.collectionView.collectionViewLayout = layouts[pageIndex]
            //self.collectionView.reloadData()
            self.collectionView.reloadSections(  NSIndexSet(index: 0) as IndexSet )
            
            if pageIndex == 0{
                toggleLButton(flag: 1)
            }else if pageIndex == numberOfPages-2{
                toggleRButton(flag: 0)
            }
        }else if flag == 1 && pageIndex < numberOfPages-1{
            // right button pressed while page index < numOfPages-1
            pageIndex += 1
            self.collectionView.collectionViewLayout = layouts[pageIndex]
            //self.collectionView.reloadData()
            self.collectionView.reloadSections(  NSIndexSet(index: 0) as IndexSet )
            (self.collectionView.collectionViewLayout as! TrigridLayout).delegate = self
            
            if pageIndex == numberOfPages-1{
                //self.collectionView.reloadData()
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
        
        
        //memeEditLauncher.pinCell = self
        //   Taking this method out and opting out for a trigrid layout since
        //     the paging collectionviews are getting ridiculous
        //self.setupLRButtons()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 288 default photos total
        // 26 images by 12?
        /*if mainController != nil{
            if pageIndex != numberOfPages{
                return imagePerPage
            }else{
                return (mainController?.photos.count)!%imagePerPage
            }
        }else{
            return 0
        }*/
        if mainController != nil{
            return (mainController?.photos.count)!
        }else{
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath) as! AnnotatedPhotoCell
        cell.photo = mainController?.photos[indexPath.item+(pageIndex*imagePerPage)]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let memeEditLauncher = MemeEditLauncher()
        
        //memeEditLauncher = MemeEditLauncher()
        //memeEditLauncher.image = mainController?.photos[(pageIndex*imagePerPage)+indexPath.item].image
        //memeEditLauncher.imgSettings(img: (mainController?.photos[(pageIndex*imagePerPage)+indexPath.item].image)!)
        memeEditLauncher.pathSettings(p: (mainController?.photos[(pageIndex*imagePerPage)+indexPath.item].path)!)
        memeEditLauncher.params = (mainController?.photos[(pageIndex*imagePerPage)+indexPath.item].params)!
        let style = mainController?.photos[(pageIndex*imagePerPage)+indexPath.item].style
        if style != "Default"{
            if style == "One-Panel"{
                memeEditLauncher.styleType = 1
            }else if style == "Two-Panel"{
                memeEditLauncher.styleType = 2
            }else if style == "Three-Panel"{
                memeEditLauncher.styleType = 3
            }else if style == "Four-Panel"{
                memeEditLauncher.styleType = 4
            }else if style == "Custom"{
                memeEditLauncher.styleType = 5
            }
        }
        memeEditLauncher.index = (pageIndex*imagePerPage)+indexPath.item
        //memeEditLauncher.pinCell = self
        //memeEditLauncher.isFav = mainController?.photos[(pageIndex*imagePerPage)+indexPath.item].isFaved()
        memeEditLauncher.favSettings(fav: (mainController?.photos[(pageIndex*imagePerPage)+indexPath.item].isFaved())!)
        
        memeEditLauncher.expandMemeView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func toggleFavorite(index:Int){
        mainController?.photos[index].toggleFav()
    }
}

//extension PinCell : PinterestLayoutDelegate {
extension PinCell : TrigridLayoutDelegate {
   
    // 1. Returns the photo height
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth width:CGFloat) -> CGFloat {
        let photo = mainController?.photos[(pageIndex*imagePerPage)+indexPath.item]
        let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect  = AVMakeRect(aspectRatio: (photo?.image.size)!, insideRect: boundingRect)
        return rect.size.height
    }
    
    // 2. Returns the annotation size based on the text
    func collectionView(_ collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let annotationPadding = CGFloat(4)
        let annotationHeaderHeight = CGFloat(17)
        let photo = mainController?.photos[(pageIndex*imagePerPage)+indexPath.item]
        let font = UIFont(name: "AvenirNext-Regular", size: 10)!
        let commentHeight = photo?.heightForComment(font, width: width)
        let height = annotationPadding + annotationHeaderHeight + commentHeight! + annotationPadding
        return height
    }
}
