//
//  FileSystemManager.swift
//  Drememe
//
//  Created by John Jin Woong Kim on 2/24/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import Foundation

class FileSystemManager{
    static let sharedInstance = FileSystemManager()
    static let directory = "/Created/"
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    func printDocumentDirectory(){
        //let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        print(paths)
    }
    
    func printAllDirectories(){
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
        print(paths)
    }
    
    func saveImageDocumentDirectory(image: UIImage, name:String){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(FileSystemManager.directory+name)//"apple.jpg")
        //let image = UIImage(named: name)//"apple.jpg")
        print(paths)
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory+FileSystemManager.directory
    }
    
    func getImage(name: String) -> UIImage{
        let fileManager = FileManager.default
        let path = getDirectoryPath()+name
        print("Attempting getImage at path ", path)
        if fileManager.fileExists(atPath: path){
            print("Image named ", name, " successfully found and retrieved")
            return (UIImage(contentsOfFile: path)?.decompressedImage)!
        }else{
            print("Image named ", name, " not found")
            return UIImage(imageLiteralResourceName: "error")
        }
    }
    
    func removeImage(name:String){
        let fileManager = FileManager.default
        let path = getDirectoryPath()+name
        print("Attempting getImage at path ", path)
        if fileManager.fileExists(atPath: path){
            print("Image named ", name, " successfully removed.")
            try! fileManager.removeItem(atPath: path)
        }else{
            print("Image named ", name, " does not exist.")
        }
    }
    
    func createDirectory(dirName: String){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(dirName)
        if !fileManager.fileExists(atPath: paths){
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        }else{
            print("Already dictionary created.")
        }
    }
    
    func deleteDirectory(dirName:String){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(dirName)
        if fileManager.fileExists(atPath: paths){
            try! fileManager.removeItem(atPath: paths)
        }else{
            print("Something wronge.")
        }
    }

}
