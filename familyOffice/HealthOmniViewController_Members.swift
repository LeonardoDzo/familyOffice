//
//  HealthOmniViewController_Members.swift
//  familyOffice
//
//  Created by Nan Montaño on 05/abr/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

extension HealthOmniViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func initMembers(){
        
        
//        let indexPath = IndexPath(item: 0, section: 0)
//        membersCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        let indexPath = IndexPath(item: 0, section: 0)
//        if(USER_SERVICE.users[0].id == membersId[indexPath.row]){
//            collectionView(membersCollectionView, didSelectItemAt: indexPath)
//        }
//    }
    
    func membersWillAppear(){
        
        membersObserver = NotificationCenter.default
            .addObserver(forName: notCenter.USER_NOTIFICATION, object: nil, queue: nil, using: {_ in
            	self.membersCollectionView.reloadData()
            })
    }
    override func viewDidAppear(_ animated: Bool) {
        membersCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    func membersWillDisappear(){
        NotificationCenter.default.removeObserver(membersObserver!)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = membersCollectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! HealthMemberCollectionViewCell
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! HealthMemberCollectionViewCell
        cell.selectedMember.isHidden = false
        cell.profileImage.loadImage(urlString: (cell.userModel?.photoURL)!)
       
        categoryTableView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! HealthMemberCollectionViewCell
        cell.selectedMember.isHidden = true
        cell.profileImage.loadImage(urlString: (cell.userModel?.photoURL)!,filter: "blackwhite")
    }
    
}
