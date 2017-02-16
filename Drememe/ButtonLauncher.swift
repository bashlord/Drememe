//
//  ButtonLauncher.swift
//  Rendezvous2
//
//  Created by John Jin Woong Kim on 2/14/17.
//  Copyright © 2017 John Jin Woong Kim. All rights reserved.
//

import Foundation
import UIKit

class Button: NSObject {
    let name: String
    let imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

class ButtonLauncher: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let cellId = "cellId"
    let imageNames = ["left", "right", "cancel", "check"]
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    var homeController: MainController?
    var memeLauncher: MemeLauncher?
    var memeEditLauncher: MemeEditLauncher?
    var flag: Int!// 0 for left, 1 for right
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.cornerRadius = 10
        //layer.masksToBounds = cornerRadius > 0
        collectionView.register(ButtonCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        
        //setupButton()
    }
    
    func setFlag(flag: Int){
        self.flag = flag
        setupButton()
    }
    
    func setupButton(){
        let button = UIView()
        if flag == 2{
            collectionView.backgroundColor = UIColor.red
        }else if flag == 3{
            collectionView.backgroundColor = UIColor.green
        }else{
            collectionView.backgroundColor = UIColor.white
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       print("ButtonLauncher:: " ,indexPath.item)
        if (memeLauncher != nil){
            if flag == 2{
                print("Cancel pressed")
                memeLauncher?.handleCancel()
            }else if flag == 3{
                print("Check pressed")
                memeLauncher?.handleEdit()
            }
        }else{
            if flag == 2{
                print("MemeEdit Cancel pressed")
                memeEditLauncher?.handleCancel()
            }else if flag == 3{
                print("Meme Edit Check pressed")
                memeEditLauncher?.handleEdit()
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ButtonCell
        print(indexPath.item)
        //cell.imageView.image = UIImage(named: imageNames[flag])?.withRenderingMode(.alwaysTemplate)
        cell.imageView.image = UIImage(named: imageNames[flag])
        cell.tintColor = UIColor.purple
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ButtonCell: BaseCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = UIColor.rgb(91, green: 14, blue: 13)
        return iv
    }()
    
    override var isHighlighted: Bool {
        didSet {
            imageView.tintColor = isHighlighted ? UIColor.white : UIColor.rgb(91, green: 14, blue: 13)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            imageView.tintColor = isSelected ? UIColor.white : UIColor.rgb(91, green: 14, blue: 13)
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addConstraintsWithFormat("H:[v0(80)]", views: imageView)
        addConstraintsWithFormat("V:[v0(80)]", views: imageView)
        
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
}
