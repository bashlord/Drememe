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
    let imageNames = ["left", "right", "cancel", "check", "delete", "clear", "save", "unstar", "star", "cancel"]
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    var pinCell: PinCell?
    var memeLauncher: MemeLauncher?
    var memeEditLauncher: MemeEditLauncher?
    var favoritesCollectionView: FavoritesCollectionView?
    var createdCollectionView: CreatedCollectionView?
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

    }
    
    func setFlag(flag: Int){
        self.flag = flag
        setupButton()
    }
    
    func setupButton(){
        let button = UIView()
        
        if flag == 9{
            collectionView.backgroundColor = UIColor.red
        }else if flag == 2{
            collectionView.backgroundColor = UIColor.red
        }else if flag == 3{
            collectionView.backgroundColor = UIColor.green
        }else if flag == 4{//smaller cancel
            collectionView.backgroundColor = UIColor.red
        }else if flag == 5{//smaller clear
            collectionView.backgroundColor = UIColor.yellow
        }else if flag == 6{//smaller save
            collectionView.backgroundColor = UIColor.green
        }else if flag == 7{//set fav
            collectionView.backgroundColor = UIColor.white
        }else if flag == 8{//is saved
            collectionView.backgroundColor = UIColor.yellow
        }else{
            collectionView.backgroundColor = UIColor.white
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       print("ButtonLauncher:: " ,indexPath.item)
        //navigation buttons
        if flag < 2{
            if flag == 0{
                pinCell?.handlePager(flag: 0)
                print("ButtonLauncher back pressed")
            }else{
                pinCell?.handlePager(flag: 1)
                print("ButtonLauncher next pressed")
            }
        }else if (memeLauncher != nil){
            //initial memeView buttons
            if flag == 2{
                print("Cancel pressed")
                memeLauncher?.handleCancel()
            }
        }else{
            // while editing memeView buttons
            if flag == 2{
                print("MemeEdit Cancel pressed")
                memeEditLauncher?.handleCancel(flag: 0)
            }else if flag == 3{
                print("Meme Edit Check pressed")
                memeEditLauncher?.handleEdit()
            }else if flag == 4{//smaller cancel
                print("Meme Edit Check pressed")
                memeEditLauncher?.handleCancel(flag: 1)
            }else if flag == 5{//smaller clear
                print("Meme Edit Clear pressed")
                memeEditLauncher?.handleClear()
            }else if flag == 6{//smaller save
                print("Meme Edit Check pressed")
                memeEditLauncher?.handleSave()
            }else if flag == 7{// set template as favorite, initally unfaved
                print("Meme Set as Favorite")
                memeEditLauncher?.handleFav(flag: 0)
                flag = 8
                collectionView.reloadItems(at: [indexPath])
                //collectionView.item
                //cell.imageView.image = UIImage(named: imageNames[flag])
            }else if flag == 8{// unset template from favorites, initially fav
                print("Meme Unset as Favorite")
                memeEditLauncher?.handleFav(flag: 1)
                flag = 7
                collectionView.reloadItems(at: [indexPath])
                //cell.imageView.image = UIImage(named: imageNames[flag])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ButtonCell
        //cell.imageView.image = UIImage(named: imageNames[flag])?.withRenderingMode(.alwaysTemplate)
        cell.imageView.image = UIImage(named: imageNames[flag])
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
        //let w = self.frame.width.
        
        //print("ButtonCell:: setupView():: ", frame.width, frame.height)
        addConstraintsWithFormat("H:[v0(\(frame.width))]", views: imageView)
        addConstraintsWithFormat("V:[v0(\(frame.height))]", views: imageView)
        
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
}
