//
//  settingLauncher.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class SettingLauncher: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    var fid = ""
    var families : Results<FamilyEntitie>!
    let blackView = UIView()
    var user : UserEntitie!
    weak var handleFamily : HandleFamilySelected!
    let collectionView = { () -> UICollectionView in
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    func showSetting() {
        if user == nil {
            user = rManager.realm.object(ofType: UserEntitie.self, forPrimaryKey: Auth.auth().currentUser?.uid)
        }
        
        fid = user.familyActive
        families = rManager.realm.objects(FamilyEntitie.self)
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            window.addSubview(blackView)
            window.addSubview(collectionView)
            
            let height : CGFloat = CGFloat(families.count * 80)
            let y = window.frame.height - height
            collectionView.frame = CGRect(x: 0, y: y, width: window.frame.width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .layoutSubviews, animations: {
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }, completion: nil)
        }
        self.collectionView.reloadData()
    }
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y:window.frame.height-0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }
        })
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return families.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! familySettingCell
        let family = families[indexPath.row]
        if !(family.photoURL.isEmpty) {
            cell.image.loadImage(urlString: family.photoURL)
        }
        if fid == family.id{
            cell.isHighlighted = true
        }else{
            cell.isHighlighted = false
        }
        cell.nameLabel.text = family.name
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let f = families[indexPath.row]
        let action = UserS()
        action.action = .selectFamily(family: f)
        store.dispatch(action)
        
        
        handleDismiss()
        if handleFamily != nil {
            userStore?.familyActive = store.state.FamilyState.families.items[indexPath.row].id
            handleFamily.selectFamily()
        }
        
    }
    
    override init(){
        super.init()
        collectionView.register(familySettingCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
    }
    
}

class BaseCell: UICollectionViewCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews()  {
    }
    override func awakeFromNib() {
    }
    
}

class familySettingCell: BaseCell {
    override var isHighlighted: Bool {
        didSet{
            backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.clear
        }
    }
    var nameLabel : UILabel = {
        let label = UILabel()
        label.text = "name"
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    lazy var image: UIImageViewX = {
        let image = UIImageViewX()
        image.image = #imageLiteral(resourceName: "familyImage")
        image.clipsToBounds = true
        image.cornerRadius = 8
        return image
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.image.circleImage()
    }
    override func setupViews() {
        super.setupViews()
        
        addSubview(nameLabel)
        addSubview(image)
        
        addContraintWithFormat(format: "H:|-8-[v0(60)]-8-[v1]|", views: image, nameLabel)
        addContraintWithFormat(format: "V:|[v0]|", views: nameLabel)
        addContraintWithFormat(format: "V:[v0(60)]", views: image)
        addConstraint(NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        image.clipsToBounds = true
        image.cornerRadius = 8
    }
}
