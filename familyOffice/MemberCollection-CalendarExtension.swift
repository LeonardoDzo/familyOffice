//
//  GuestMembersTableViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cant = 0
        if cant == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nomemberCell", for: indexPath)
            return cell
        }else  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! MemberCollectionViewCell
            cell.image.image = #imageLiteral(resourceName: "profile_default")
            let id: String = dates[collectionView.tag].members[indexPath.row].id
            if !id.isEmpty {
                if let user = service.USER_SERVICE.users.filter({$0.id == id}).first {
                    if !user.photoURL.isEmpty {
                        cell.image.loadImage(urlString: user.photoURL)
                    }
                }else{
                    service.REF_SERVICE.valueSingleton(ref: "users/\(id)")
                }
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cant: Int! = 0
        if cant == 0 {
            return CGSize(width: collectionView.frame.width, height: 30)
        }
        return CGSize(width: 30, height: 30)
    }
   

    
    
    
}
