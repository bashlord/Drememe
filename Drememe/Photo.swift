//
//  Photo.swift
//  Rendezvous2
//
//  Created by John Jin Woong Kim on 2/12/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import UIKit
import CoreFoundation

class Param{
    var width: CGFloat
    var height: CGFloat
    var offset_w: CGFloat
    var offset_h: CGFloat
    
    var w: CGFloat = 0
    var h: CGFloat = 0
    var o_w: CGFloat = 0
    var o_h: CGFloat = 0
    
    var scalar_h: CGFloat? {
        didSet {
            if let scalar_h = scalar_h {
                h = height*scalar_h
                o_h = offset_h*scalar_h
            }
        }
    }
    
    var scalar_w: CGFloat? {
        didSet {
            if let scalar_w = scalar_w {
                w = width*scalar_w
                o_w = offset_w*scalar_w
            }
        }
    }
    
    init(a:Int, b:Int, c:Int, d:Int) {
        self.width = CGFloat(a)
        self.height = CGFloat(b)
        self.offset_w = CGFloat(c)
        self.offset_h = CGFloat(d)
    }
    
    convenience init(dictionary: NSDictionary) {
        //let photo = dictionary["Photo"] as? String
        //let image = UIImage(named: photo!)?.decompressedImage
        let a = dictionary["width"] as? Int
        let b = dictionary["height"] as? Int
        let c = dictionary["offset_w"] as? Int
        let d = dictionary["offset_h"] as? Int
        self.init(a:a!, b:b!, c:c!, d:d!)
    }
}

class Photo {
    //let memeURLS = CFArray()
    class func allPhotos() -> [Photo] {
        var photos = [Photo]()
        var i = 0
        if let URL = Bundle.main.url(forResource: "Photos", withExtension: "plist") {
            if let photosFromPlist = NSArray(contentsOf: URL) {
                for dictionary in photosFromPlist {
                    let photo = Photo(dictionary: dictionary as! NSDictionary)
                    photo.index = i
                    photos.append(photo)
                    i += 1
                }
            }
        }
        print("Photo::  allPhotos() returning")
        return photos
    }
    
    class func allFavorites() -> [Int]{
        var favs = [Int]()
        let dictionary = PlistManager.sharedInstance.getPlist(flag: 0)
        for val in dictionary.allValues{
            favs.append((val as? Int)!)
            print((val as? Int)!)
        }
        return favs
    }

    var image: UIImage
    var path: String
    var style: String
    var params = [Param]()
    var index = 0
    var isFav = false
    init(image: UIImage, path:String, p:[Param], s:String) {
        self.image = image
        self.path = path
        self.params = p
        self.style = s
    }
    
    convenience init(dictionary: NSDictionary) {
        var params = [Param]()
        let photo = dictionary["Photo"] as? String
        let image = UIImage(named: photo!)?.decompressedImage
        let style = dictionary["Style"] as? String
        if style != "Default"{
            let ps = dictionary["Param"] as? NSArray
            for dict in ps!{
                let p = Param(dictionary: dict as! NSDictionary)
                params.append(p)
            }
        }
        self.init(image: image!, path: photo!,p: params, s:style!)
    }
    
    func heightForComment(_ font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: "").boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.height)
    }
    
    func toggleFav(){
        if isFav == true{
            isFav = false
        }else{
            isFav = true
        }
    }
    
    func isFaved() -> Bool{
        return isFav
    }
}
