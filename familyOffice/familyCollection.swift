//
//  familyCollection.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 15/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit


extension SelectCategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,  UIGestureRecognizerDelegate{
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return families != nil ? families.count + 1 : 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if families != nil,  indexPath.row < families.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FamiliesPreCollectionViewCell
            let family = families[indexPath.item]
            cell.bind(fam: family)
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath)
       
        return cell
        
    }
    func addFamily(family: Family) -> Void {
        self.familiesCollection.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        //Where elements_count is the count of all your items in that
        //Collection view...
        let count = (families != nil ? families.count : 0 ) + 1
        let cellCount = CGFloat(count)
        
        //If the cell count is zero, no point in calculating anything.
        if cellCount > 0 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            
            //20.00 was just extra spacing I wanted to add to my cell.
            let totalCellWidth = cellWidth*cellCount + 20.00 * (cellCount-1)
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
            
            if (totalCellWidth < contentWidth) {
                //If the number of cells that exist take up less room than the
                // collection view width... then there is an actual point to centering the.
                
                //Calculate the right amount of padding to center the cells.
                let padding = (contentWidth - totalCellWidth) / 2.0
                return UIEdgeInsetsMake(0, padding, 0, padding)
            } else {
                //Pretty much if the number of cells that exist take up
                // more room than the actual collectionView width there is no
                // point in trying to center them. So we leave the default behavior.
                return UIEdgeInsetsMake(0, 40, 0, 40)
            }
        }
        
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(families == nil || indexPath.row == families.count){
           promptForAnswer()
        }else{
            let family = families[(indexPath.row)]
            self.toggleSelect(family: family)
            self.familiesCollection.reloadData()
            self.pushToView(view: .profileFamily, sender: family)
            
        }
    }
    func promptForAnswer() {
        let alertController = UIAlertController(title: "Crear Familia", message: "Ingresa el nombre de la familia", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Crear", style: .default) { (_) in
            
            guard let text = alertController.textFields?[0].text, !text.isEmpty else {
                return
            }
            let family = FamilyEntitie()
            family.name = text
            store.dispatch(FamilyS(.insert(family: family)))
            
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Nombre de la familia"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    func toggleSelect(family: FamilyEntitie){
        store.dispatch(UserS( .selectFamily(family: family)))
    }
    
}
