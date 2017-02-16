//
//  AnnotatedPhotoCell.swift
//  Rendezvous2
//
//  Created by John Jin Woong Kim on 2/12/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import UIKit

class AnnotatedPhotoCell: BaseCell {
    
    //fileprivate weak var imageView: UIImageView!
    //fileprivate weak var imageViewHeightLayoutConstraint: NSLayoutConstraint!
    //fileprivate weak var captionLabel: UILabel!
    //fileprivate weak var commentLabel: UILabel!
    
    var photo: Photo? {
        didSet {
            if let photo = photo {
                imageView.image = photo.image
                captionLabel.text = ""
                commentLabel.text = ""
                setupViews()
            }
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        //iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .green
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()
    
    let captionLabel: UILabel = {
        let l = UILabel()
        return l
    }()
    
    let commentLabel: UILabel = {
        let l = UILabel()
        return l
    }()
    
    var imageViewHeightLayoutConstraint: NSLayoutConstraint?
    var imageViewWidthLayoutConstraint: NSLayoutConstraint?
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? PinterestLayoutAttributes {
            imageViewHeightLayoutConstraint?.constant = attributes.photoHeight
            
            //imageViewWidthLayoutConstraint?.constant = attributes.photoHeight
            print("AnnotatedPhotoCell:: apply ", imageViewHeightLayoutConstraint?.constant)
            
        }
    }
    
    override func setupViews() {
        super.setupViews()
        if photo != nil{
            print("AnnotatedPhotoCell:: photo not null")
            imageView.image = photo?.image
            addSubview(imageView)
            addSubview(captionLabel)
            addSubview(commentLabel)
            
            imageViewHeightLayoutConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self, attribute: .height, multiplier: 1, constant: 0)
            addConstraint(imageViewHeightLayoutConstraint!)
            
            
            imageViewWidthLayoutConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 1, constant: 0)
            addConstraint(imageViewWidthLayoutConstraint!)
            
            
            addConstraintsWithFormat("H:|[v0]|", views: imageView)
            addConstraintsWithFormat("V:|[v0]|", views: imageView)
            addConstraintsWithFormat("H:|[v0]|", views: captionLabel)
            addConstraintsWithFormat("H:|[v0]|", views: commentLabel)
            
            
        }
        
    }
}

