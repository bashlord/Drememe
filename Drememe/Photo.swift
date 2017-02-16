//
//  Photo.swift
//  Rendezvous2
//
//  Created by John Jin Woong Kim on 2/12/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import UIKit
import CoreFoundation
class Photo {
    //let memeURLS = CFArray()
    class func allPhotos() -> [Photo] {
        var photos = [Photo]()
        if let URL = Bundle.main.url(forResource: "Photos", withExtension: "plist") {
            if let photosFromPlist = NSArray(contentsOf: URL) {
                for dictionary in photosFromPlist {
                    let temp = dictionary as! NSDictionary
                    let photo = Photo(dictionary: dictionary as! NSDictionary)
                    photos.append(photo)
                }
            }
        }
        print("Photo::  allPhotos() returning")
        return photos
    }
    
    //var caption: String
    //var comment: String
    var image: UIImage
    var path: String
    
    //init(caption: String, comment: String, image: UIImage) {
    init(image: UIImage, path:String) {
        //self.caption = caption
        //self.comment = comment
        self.image = image
        self.path = path
    }
    
    convenience init(dictionary: NSDictionary) {
        //let caption = dictionary["Caption"] as? String
        //let comment = dictionary["Comment"] as? String
        //let path = dictionary["Path"] as? String
        let photo = dictionary["Photo"] as? String
        let image = UIImage(named: photo!)?.decompressedImage
        self.init(image: image!, path: photo!)
        print("image init size ", image?.size.width, image?.size.height)
        
        //self.init(dictionary: image!)
        
    }
    
    func heightForComment(_ font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: "").boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.height)
    }
    
}
