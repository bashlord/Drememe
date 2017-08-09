//
//  TrigridLayout.swift
//  Rendezvous2
//
//  Created by John Jin Woong Kim on 2/12/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import UIKit
protocol TrigridLayoutDelegate {
    // 1. Method to ask the delegate for the height of the image
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth:CGFloat) -> CGFloat
    // 2. Method to ask the delegate for the height of the annotation text
    func collectionView(_ collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
    
}

class TrigridLayoutAttributes:UICollectionViewLayoutAttributes {
    
    // 1. Custom attribute
    var photoHeight: CGFloat = 0.0
    
    // 2. Override copyWithZone to conform to NSCopying protocol
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! TrigridLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }
    
    // 3. Override isEqual
    override func isEqual(_ object: Any?) -> Bool {
        if let attributtes = object as? TrigridLayoutAttributes {
            if( attributtes.photoHeight == photoHeight  ) {
                return super.isEqual(object)
            }
        }
        return false
    }
}


class TrigridLayout: UICollectionViewFlowLayout {
    var page = -1
    //1. Trigrid Layout Delegate
    var delegate:TrigridLayoutDelegate!
    
    //2. Configurable properties
    var numberOfColumns = 3
    var cellPadding: CGFloat = 1.0
    
    //3. Array to keep a cache of attributes.
    fileprivate var cache = [TrigridLayoutAttributes]()
    
    //4. Content height and size
    fileprivate var contentHeight:CGFloat  = 0.0
    fileprivate var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    func cacheSize() -> Int {
        return cache.count
    }
    
    func resetCache(){
        self.cache.removeAll()
    }
    
    override class var layoutAttributesClass : AnyClass {
        return TrigridLayoutAttributes.self
    }
    
    override func prepare() {
        print("TrigridLayout:: prepare() called")
        // 1. Only calculate once
        //if cache.isEmpty {
        if cache.count < collectionView!.numberOfItems(inSection: 0) || cache.isEmpty{
            print("TrigridLayout:: prepare() isEmpty being clled? page cache.count collectionView.numOfItems", page, cache.count, collectionView!.numberOfItems(inSection: 0))
            // 2. Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            let i = 0
            if !cache.isEmpty{
                cache.removeAll()
            }
            // 3. Iterates through the list of items in the first section
            for item in i ..< collectionView!.numberOfItems(inSection: 0) {
                
                let indexPath = IndexPath(item: item, section: 0)
                
                // 4. Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
                let width = columnWidth - cellPadding*2
                let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath , withWidth:width)
                let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
                let height = cellPadding +  photoHeight + annotationHeight + cellPadding
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                // 5. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
                let attributes = TrigridLayoutAttributes(forCellWith: indexPath)
                attributes.photoHeight = photoHeight
                attributes.frame = insetFrame
                cache.append(attributes)
                
                // 6. Updates the collection view content height
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                //column += 1
                if column >= (numberOfColumns - 1){
                    column = 0
                }else{
                    column += 1
                }
                //column = column >= (numberOfColumns - 1) ? 0 : column += 1
                //column = column >= (numberOfColumns - 1) ? 0 : ++column
                
            }
        }else if cache.count > collectionView!.numberOfItems(inSection: 0){
            print("TrigridLayout:: prepare() cache size > collectionView size")
            print("page cache.count collectionView.numberOfItems", page, cache.count, collectionView!.numberOfItems(inSection: 0))
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            let i = 0
            if !cache.isEmpty{
                cache.removeAll()
            }
            for item in i ..< collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let width = columnWidth - cellPadding*2
                let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath , withWidth:width)
                let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
                let height = cellPadding +  photoHeight + annotationHeight + cellPadding
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                let attributes = TrigridLayoutAttributes(forCellWith: indexPath)
                attributes.photoHeight = photoHeight
                attributes.frame = insetFrame
                cache.append(attributes)
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                //column += 1
                if column >= (numberOfColumns - 1){
                    column = 0
                }else{
                    column += 1
                }
            }
        }
    }
    
    override var collectionViewContentSize : CGSize {
        //print("TrigridLayout CGSize() called", contentWidth, contentHeight)
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes  in cache {
            if attributes.frame.intersects(rect ) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    
}
