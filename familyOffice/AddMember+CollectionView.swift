//
//  AddMember+CollectionView.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 08/02/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit

extension AddMembersTableViewController:  UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return selected.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellMember", for: indexPath) as! memberSelectedCollectionViewCell
        
        let user = selected[indexPath.row]
        cell.bind(userModel: user)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: IndexPath(row: users.index(where: {$0.id == selected[indexPath.row].id})!, section: 1), animated: true)
        selected.remove(at: indexPath.row)
        reload()
        collectionView.deleteItems(at: [indexPath])
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section > 0){
            let selUser = users[indexPath.row]
            if !selected.contains(where: {$0.id == selUser.id}) {
                selected.append(selUser)
                
                firstCell.collectionView.insertItems(at: [IndexPath(item: selected.count-1, section: 0)])
                reload()
            }
        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selUser = users[indexPath.row]
        let index = IndexPath(item: selected.index(where: {$0.id == selUser.id})!, section: 0)
        if(indexPath.section > 0){
            selected.remove(at: selected.index(where: {$0.id == selUser.id})!)
            firstCell.collectionView.deleteItems(at: [index])
            reload()
        }
    }
    func reload() -> Void {
        if(selected.count <= 1 ){
            tableView.reloadRows(at: [IndexPathOfFirstRow as IndexPath], with: UITableViewRowAnimation.automatic)
        }
        
    }
    
}
