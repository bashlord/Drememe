//
//  MemeEditLauncherExt.swift
//  Drememe
//
//  Created by John Jin Woong Kim on 2/21/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import Foundation

extension MemeEditLauncher{
    func createTextView() -> UITextView {
        let textView = UITextView()
        textView.typingAttributes = memeFont
        textView.textAlignment = .center
        textView.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        textView.text = ""
        textView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        textView.returnKeyType = .done
        return textView
    }
    
    func setTextView(i: Int){
        if i == 3{
            self.thirdTextView = createTextView()
            self.thirdTextView.delegate = self
        }else if i == 4{
            self.fourthTextView = createTextView()
            self.fourthTextView.delegate = self
        }
    }
    
    func areTextViewsSet() -> Bool {
        if self.topText.text.isEmpty || self.bottomText.text.isEmpty{
            return false
        }
        
        //I realize that this is a hacky way of checking, will prob
        //  need to have an iterative way implemented lateer
        
        //if third/fourth textView exists, but has empty text
        if self.thirdTextView != nil && self.thirdTextView.text.isEmpty{
            return false
        }
        if self.fourthTextView != nil && self.fourthTextView.text.isEmpty{
            return false
        }
        
        return true
    }
    
    func getCustomTextViews(n: Int){
        customTextViews.append(topText)
        if params.count > 1{
            customTextViews.append(bottomText)
        }
        if params.count > 2{
            setTextView(i: 3)
            customTextViews.append(thirdTextView)
        }
        if params.count > 3{
            setTextView(i: 4)
            customTextViews.append(fourthTextView)
        }
    }
    
    // The difference between default and 2panel is that
    //  a default would have textviews aligning with the top
    //  and bottom of an image while 2panel aligns with the top
    //  and the center of an image
    func twoPanelTextViewAnimation(phase: Int){
        if phase == 0{
            topText.frame = CGRect(x: 0, y: 0 - ((2*imageView.frame.height)/5), width: imageView.frame.width, height: ((2*imageView.frame.height)/5))
            bottomText.frame = CGRect(x: 0, y: 0 - ((2*imageView.frame.height)/5), width: imageView.frame.width, height: ((2*imageView.frame.height)/5))
            topText.contentSize.height = topText.frame.height
            topText.contentSize.width = topText.frame.width
            bottomText.contentSize.height = topText.frame.height
            bottomText.contentSize.width = bottomText.frame.width
            self.view.addSubview(topText)
            self.view.addSubview(bottomText)
        }else if phase == 1{
            topText.frame.origin.y += self.heightOffset + self.topText.frame.height
            bottomText.frame.origin.y += self.heightOffset + self.topText.frame.height + (1.25 * self.topText.frame.height)
        }else if phase == 2{
            self.topText.frame.origin.y -= self.topText.frame.height
            self.bottomText.frame.origin.y -= self.topText.frame.height + (1.25 * self.topText.frame.height)
        }else if phase == 3{
            self.topText.removeFromSuperview()
            self.bottomText.removeFromSuperview()
        }
    }
    
    func threePanelTextViewAnimation(phase: Int){
        if phase == 0{
            setTextView(i: 3)
            topText.frame = CGRect(x: 0, y: 0 - ((imageView.frame.height)/6), width: imageView.frame.width, height: ((imageView.frame.height)/6))
            bottomText.frame = CGRect(x: 0, y: 0 - ((imageView.frame.height)/6), width: imageView.frame.width, height: ((imageView.frame.height)/6))
            thirdTextView?.frame = CGRect(x: 0, y: 0 - ((imageView.frame.height)/6), width: imageView.frame.width, height: ((imageView.frame.height)/6))
            topText.contentSize.height = topText.frame.height
            topText.contentSize.width = topText.frame.width
            bottomText.contentSize.height = topText.frame.height
            bottomText.contentSize.width = bottomText.frame.width
            thirdTextView?.contentSize.height = topText.frame.height
            thirdTextView.contentSize.width = topText.frame.width
            self.view.addSubview(topText)
            self.view.addSubview(bottomText)
            self.view.addSubview(thirdTextView)
        }else if phase == 1{
            topText.frame.origin.y += self.heightOffset + self.topText.frame.height
            bottomText.frame.origin.y += self.heightOffset + self.topText.frame.height + (2 * self.topText.frame.height)
            thirdTextView.frame.origin.y += self.heightOffset + self.topText.frame.height + (4 * self.topText.frame.height)
        }else if phase == 2{
            self.topText.frame.origin.y -= self.topText.frame.height
            self.bottomText.frame.origin.y -= self.topText.frame.height + (2 * self.topText.frame.height)
            thirdTextView.frame.origin.y -= self.heightOffset + self.topText.frame.height + (4 * self.topText.frame.height)
        }else if phase == 3{
            self.topText.removeFromSuperview()
            self.bottomText.removeFromSuperview()
            self.thirdTextView.removeFromSuperview()
        }
    }
    
    func fourPanelTextViewAnimation(phase: Int){
        if phase == 0{
            setTextView(i: 3)
            setTextView(i: 4)
            topText.frame = CGRect(x: 0, y: 0 - ((imageView.frame.height)/4), width: imageView.frame.width/2, height: ((imageView.frame.height)/4))
            bottomText.frame = CGRect(x: imageView.frame.width/2, y: 0 - ((imageView.frame.height)/4), width: imageView.frame.width/2, height: ((imageView.frame.height)/4))
            thirdTextView?.frame = CGRect(x: 0, y: 0 - ((imageView.frame.height)/4), width: imageView.frame.width/2, height: ((imageView.frame.height)/4))
            fourthTextView?.frame = CGRect(x: imageView.frame.width/2, y: 0 - ((imageView.frame.height)/4), width: imageView.frame.width/2, height: ((imageView.frame.height)/4))
            topText.contentSize.height = topText.frame.height
            topText.contentSize.width = topText.frame.width
            bottomText.contentSize.height = topText.frame.height
            bottomText.contentSize.width = bottomText.frame.width
            thirdTextView?.contentSize.height = topText.frame.height
            thirdTextView.contentSize.width = topText.frame.width
            fourthTextView?.contentSize.height = topText.frame.height
            fourthTextView.contentSize.width = topText.frame.width
            self.view.addSubview(topText)
            self.view.addSubview(bottomText)
            self.view.addSubview(thirdTextView)
            self.view.addSubview(fourthTextView)
        }else if phase == 1{
            topText.frame.origin.y += self.heightOffset + self.topText.frame.height
            bottomText.frame.origin.y += self.heightOffset + self.topText.frame.height// + (2 * self.topText.frame.height)
            thirdTextView.frame.origin.y += self.heightOffset + self.topText.frame.height + (2 * self.topText.frame.height)
            fourthTextView.frame.origin.y += self.heightOffset + self.topText.frame.height + (2 * self.topText.frame.height)
        }else if phase == 2{
            self.topText.frame.origin.y -= self.topText.frame.height
            self.bottomText.frame.origin.y -= self.topText.frame.height// + (2 * self.topText.frame.height)
            thirdTextView.frame.origin.y -= self.heightOffset + self.topText.frame.height + (2 * self.topText.frame.height)
            fourthTextView.frame.origin.y -= self.heightOffset + self.topText.frame.height + (2 * self.topText.frame.height)
        }else if phase == 3{
            self.topText.removeFromSuperview()
            self.bottomText.removeFromSuperview()
            self.thirdTextView.removeFromSuperview()
            self.fourthTextView.removeFromSuperview()
        }
    }
    
    func customTextViewAnimate(phase: Int){
        if phase == 0{
            getCustomTextViews(n: params.count)
            var i = 0
            for textView in customTextViews{
                //textView.frame = CGRect(x: params[i].o_w, y: params[i].o_h, width: params[i].w, height: params[i].h)
                textView.frame = CGRect(x: params[i].o_w, y: -params[i].h, width: params[i].w, height: params[i].h)
                textView.contentSize.height = textView.frame.height
                textView.contentSize.width = textView.frame.width
                self.view.addSubview(textView)
                i += 1
            }
            /*
            topText.frame = CGRect(x: 0, y: 0 - ((2*imageView.frame.height)/5), width: imageView.frame.width, height: ((2*imageView.frame.height)/5))
            bottomText.frame = CGRect(x: 0, y: 0 - ((2*imageView.frame.height)/5), width: imageView.frame.width, height: ((2*imageView.frame.height)/5))
            topText.contentSize.height = topText.frame.height
            topText.contentSize.width = topText.frame.width
            bottomText.contentSize.height = topText.frame.height
            bottomText.contentSize.width = bottomText.frame.width
            self.view.addSubview(topText)
            self.view.addSubview(bottomText)
             */
        }else if phase == 1{
            //topText.frame.origin.y += self.heightOffset + self.topText.frame.height
            //bottomText.frame.origin.y += self.heightOffset + self.topText.frame.height + (1.5 * self.topText.frame.height)
            var i = 0
            for textView in customTextViews{
                textView.frame.origin.y += self.heightOffset + textView.frame.height + params[i].o_h
                i += 1
            }
        }else if phase == 2{
            //self.topText.frame.origin.y -= self.topText.frame.height
            //self.bottomText.frame.origin.y -= self.topText.frame.height + (1.5 * self.topText.frame.height)
            var i = 0
            for textView in customTextViews{
                textView.frame.origin.y -= textView.frame.height + textView.frame.origin.y
                i += 1
            }
        }else if phase == 3{
            //self.topText.removeFromSuperview()
            //self.bottomText.removeFromSuperview()
            
            for textView in customTextViews{
                textView.removeFromSuperview()
            }
        }
    }
    
    func defaultTextViewAnimate(phase: Int){
        if phase == 0{
            topText.frame = CGRect(x: 0, y: 0 - ((2*imageView.frame.height)/5), width: imageView.frame.width, height: ((2*imageView.frame.height)/5))
            bottomText.frame = CGRect(x: 0, y: 0 - ((2*imageView.frame.height)/5), width: imageView.frame.width, height: ((2*imageView.frame.height)/5))
            topText.contentSize.height = topText.frame.height
            topText.contentSize.width = topText.frame.width
            bottomText.contentSize.height = topText.frame.height
            bottomText.contentSize.width = bottomText.frame.width
            self.view.addSubview(topText)
            self.view.addSubview(bottomText)
        }else if phase == 1{
            topText.frame.origin.y += self.heightOffset + self.topText.frame.height
            bottomText.frame.origin.y += self.heightOffset + self.topText.frame.height + (1.5 * self.topText.frame.height)
        }else if phase == 2{
            self.topText.frame.origin.y -= self.topText.frame.height
            self.bottomText.frame.origin.y -= self.topText.frame.height + (1.5 * self.topText.frame.height)
        }else if phase == 3{
            self.topText.removeFromSuperview()
            self.bottomText.removeFromSuperview()
        }
    }

    
    
}
