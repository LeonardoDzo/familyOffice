//
//  ProfileUserViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ProfileUserViewController: UIViewController, UserModelBindable {
    var phKeys = [("Nombre","name"), ("Teléfono","phone"), ("Dirección","address"), ("Fecha de Cumpleaños","birthday"), ("RFC","rfc"), ("CURP","curp"), ("NSS","nss"), ("Tipo de sangre","bloodType")]
    var families = [Family]()
    var userModel: User?
    var filter: String!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var familiesCollection: UICollectionView!
    @IBOutlet weak var infoTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileImage.profileUser()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.bind()
        self.families = store.state.FamilyState.families.items.filter({ f in
            return (userModel?.families?.allKeys.contains(where: { f1 in
                if let fid = f1 as? String {
                    return fid == f.id
                }
                return false
            }))!
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    @IBAction func handleChangeSegmented(_ sender: UISegmentedControl) {
        infoTable.isHidden = sender.selectedSegmentIndex == 0 ? false : true
        familiesCollection.isHidden = sender.selectedSegmentIndex == 0 ? true : false
    }
    
}
extension ProfileUserViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return phKeys.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PersonalDataTableViewCell
        cell.myTextField.isEnabled = false
        let obj = phKeys[indexPath.row]
        cell.configure(text: userModel?.toDictionary().object(forKey: obj.1) as! String!, placeholder: obj.0)
        return cell
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        service.UTILITY_SERVICE.moveTextField(textField: textField, moveDistance: -200, up: true, context: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        service.UTILITY_SERVICE.moveTextField(textField: textField, moveDistance: -200, up: false, context: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension ProfileUserViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return families.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FamilyCollectionViewCell
        _ = families[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        //Where elements_count is the count of all your items in that
        //Collection view...
        let cellCount = CGFloat(families.count)
        
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
    
    
    
}



