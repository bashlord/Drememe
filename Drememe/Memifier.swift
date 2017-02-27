//
//  Memifier.swift
//  Drememe
//
//  Created by John Jin Woong Kim on 2/26/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import Foundation
/*
 func memify(img: UIImage, textView1: UITextView, textView2: UITextView){
 let originalImg = img
 //print("Original Image size/width/height ", originalImg.size, originalImg.size.width, originalImg.size.height)
 let imageView = UIImageView(frame: CGRect(origin: .zero, size: originalImg.size))
 imageView.image = originalImg
 topText.backgroundColor = UIColor(white: 0, alpha: 0)
 imageView.addSubview(topText)
 UIGraphicsBeginImageContext(originalImg.size)
 
 
 //originalImg.draw(in: CGRect(origin: .zero, size: originalImg.size))
 //textView1.backgroundColor = UIColor(white: 0, alpha: 0)
 //textView1.layer.draw(in: CGRect(x: 50, y: 50, width: 100, height: 100) as! CGContext)
 let context = UIGraphicsGetCurrentContext()
 
 imageView.layer.render(in: context!)
 
 if context == nil{
 print("memify failed, nil context")
 }else{
 print("memify has a context...")
 
 //textView1.layer.render(in: context!)
 //textView2.layer.render(in: context!)
 let image = UIGraphicsGetImageFromCurrentImageContext()
 
 UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
 }
 }
 */
// take in textViews, return original image with textView layer, also
//  with the textView background color being clear

class Memifier{
    static let sharedInstance = Memifier()
    private init(){}
    
    
    func createImage(orgImage: UIImage, style: Int, params: [Param], texts: [String]) -> UIImage{
        var textViews = [UITextView]()
        // this should be populating the array og
        // textViews in order properly...
        if style != 5{
            textViews.append(contentsOf: initTextViews(styleFlag: style, frame: CGRect(origin: .zero, size: orgImage.size)))
        }else{
            textViews.append(contentsOf: initCustomTextViews(params: params))
        }
        
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: orgImage.size))
        imageView.image = orgImage
        
        UIGraphicsBeginImageContext(orgImage.size)
        let context = UIGraphicsGetCurrentContext()
        var i = 0
        for tv in textViews{
            var currentFontSize: CGFloat = 40.0
            
            tv.backgroundColor = UIColor(white: 0, alpha: 0)
            tv.textAlignment = .center
            tv.autocapitalizationType = UITextAutocapitalizationType.allCharacters
            
            tv.attributedText = resizeFont(str: texts[i],fontSize: CGFloat(currentFontSize))
            tv.textAlignment = .center
            tv.autocapitalizationType = UITextAutocapitalizationType.allCharacters
            currentFontSize += 1
            while tv.contentSize.height < tv.frame.size.height && currentFontSize < 100{
                tv.attributedText = resizeFont(str: texts[i],fontSize: CGFloat(currentFontSize))
                tv.textAlignment = .center
                tv.autocapitalizationType = UITextAutocapitalizationType.allCharacters
                currentFontSize += 1
            }
            print("Current font size set at ", currentFontSize)
            imageView.addSubview(tv)
            i += 1
        }
        imageView.layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        //UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
        
        return image!
     }
 
    func resizeFont( str:String, fontSize: CGFloat) -> NSAttributedString{
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: fontSize)!,
            NSStrokeWidthAttributeName : -4.0
            ] as [String : Any]
        let newAttr = NSAttributedString(string: str, attributes: memeTextAttributes)
        
        return newAttr
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        }
    }
    
    func initCustomTextViews(params: [Param]) -> [UITextView]{
        var tv  = [UITextView]()
        for p in params{
            let textView = UITextView()
            textView.frame = CGRect(x: p.offset_w, y: p.offset_h, width: p.width, height: p.height)
            textView.contentSize.width = textView.frame.width
            textView.contentSize.height = textView.frame.height
            tv.append(textView)
        }
        
        return tv
    }
    
    func initTextViews(styleFlag: Int, frame: CGRect) -> [UITextView]{
        var tv = [UITextView]()
        if styleFlag == 0{//default
            tv.append(UITextView())
            tv.append(UITextView())
            
            tv[0].frame = CGRect(x: 0, y: 0, width: frame.width, height: ((2*frame.height)/5))
            tv[1].frame = CGRect(x: 0, y: ((3*frame.height)/5), width: frame.width, height: ((2*frame.height)/5))
            tv[0].contentSize.height = tv[0].frame.height
            tv[0].contentSize.width = tv[0].frame.width
            tv[1].contentSize.height = tv[1].frame.height
            tv[1].contentSize.width = tv[1].frame.width
        }else if styleFlag == 2{// 2 panel with the bottom aligning the middle
            tv.append(UITextView())
            tv.append(UITextView())
            
            tv[0].frame = CGRect(x: 0, y: 0, width: frame.width, height: ((2*frame.height)/5))
            tv[1].frame = CGRect(x: 0, y: ((2.5*frame.height)/5), width: frame.width, height: ((2*frame.height)/5))
            tv[0].contentSize.height = tv[0].frame.height
            tv[0].contentSize.width = tv[0].frame.width
            tv[1].contentSize.height = tv[1].frame.height
            tv[1].contentSize.width = tv[1].frame.width
        }else if styleFlag == 3{
            tv.append(UITextView())
            tv.append(UITextView())
            tv.append(UITextView())
            
            tv[0].frame = CGRect(x: 0, y: 0, width: frame.width, height: ((frame.height)/6))
            tv[1].frame = CGRect(x: 0, y: ((1*frame.height)/3), width: frame.width, height: ((frame.height)/6))
            tv[2].frame = CGRect(x: 0, y: ((2*frame.height)/3), width: frame.width, height: ((frame.height)/6))
            
            tv[0].contentSize.height = tv[0].frame.height
            tv[0].contentSize.width = tv[0].frame.width
            tv[1].contentSize.height = tv[1].frame.height
            tv[1].contentSize.width = tv[1].frame.width
            tv[2].contentSize.height = tv[2].frame.height
            tv[2].contentSize.width = tv[2].frame.width
        }else if styleFlag == 4{
            tv.append(UITextView())
            tv.append(UITextView())
            tv.append(UITextView())
            tv.append(UITextView())
            
            tv[0].frame = CGRect(x: 0, y: 0, width: frame.width/2, height: ((frame.height)/4))
            tv[1].frame = CGRect(x: frame.width/2, y: 0, width: frame.width/2, height: ((frame.height)/4))
            
            tv[2].frame = CGRect(x: 0, y: ((frame.height)/2), width: frame.width/2, height: ((frame.height)/4))
            tv[3].frame = CGRect(x: frame.width/2, y: ((frame.height)/2), width: frame.width/2, height: ((frame.height)/4))
            
            tv[0].contentSize.height = tv[0].frame.height
            tv[0].contentSize.width = tv[0].frame.width
            tv[1].contentSize.height = tv[1].frame.height
            tv[1].contentSize.width = tv[1].frame.width
            tv[2].contentSize.height = tv[2].frame.height
            tv[2].contentSize.width = tv[2].frame.width
            tv[3].contentSize.height = tv[3].frame.height
            tv[3].contentSize.width = tv[3].frame.width
        }
        return tv
    }


}






