//
//  CreatedPhotosManager.swift
//  Drememe
//
//  Created by John Jin Woong Kim on 2/25/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import Foundation

class PhotoNode{
    var indexPath: Int
    var path: String
    var compImage: UIImage
    var orgImage: UIImage
    
    init(path: Int, c: UIImage, o:UIImage) {
        self.indexPath = path
        self.path = String(path)
        self.compImage = c
        self.orgImage = o
    }

}

class CreatedPhotosManager{
    // Decided to just make a manager for the created photos due to their
    //  awkward situation of requiring not only the pre made static plists
    //  but also requiring a filesystem manager as well to read/write/edit
    //  existing mutable directories, unlike the blank templates which
    //  will remain static and unlike the favorites photos, which only 
    //  require a plist manager to hold indexes of templates that have been
    //  saved.
    
    //i realize how silly it is to just use incrementing numbers
    // for the pathnames of the images, but reallly it is the simplest form
    // to use as well as the easiest generator of unique key names
    var photos = [PhotoNode]()
    init() {
        self.photos = allCreatedPaths()
    }
    
    class func allCreated() -> [Int]{
        var favs = [Int]()
        let dictionary = PlistManager.sharedInstance.getPlist(flag: 1)
        for val in dictionary.allValues{
            favs.append((val as? Int)!)
            print((val as? Int)!)
        }
        return favs
    }
    
    func allCreatedPaths() -> [PhotoNode]{
        var pn = [PhotoNode]()
        let dictionary = PlistManager.sharedInstance.getPlist(flag: 1)
        for val in dictionary.allValues{
            let i = (val as? Int)!
            print(i)
            let image = FileSystemManager.sharedInstance.getImage(name: "\(i).jpg")
            let comImg = (FileSystemManager.sharedInstance.getImage(name: "\(i).jpg")).decompressedImage
            pn.append(PhotoNode(path: i, c: image, o: comImg))
        }
        return pn
    }
    
    func getOriginalImage(index: Int) ->UIImage {
        return self.photos[index].orgImage
    }
    
    func getAnnotatedImage(index: Int) -> UIImage {
        return self.photos[index].compImage
    }
    
    func getNewPathIndex() -> Int{
        if photos.count == 0{
            return 0
        }else{
            return photos[photos.count-1].indexPath+1
        }
    }
    
    func getCount() -> Int{
        return photos.count
    }

}
