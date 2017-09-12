//
//  HealthOmniViewController_Categories.swift
//  familyOffice
//
//  Created by Nan Montaño on 07/abr/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

extension HealthOmniViewController : UITableViewDelegate, UITableViewDataSource {
    
    func initElements(){
        
    }
    
    @IBAction func categoryClick(_ sender: UIButton) {
    

    }
    
    func elementsWillAppear(){
        
        
    }
    
    func elementsWillDisappear(){
        NotificationCenter.default.removeObserver(elementAddedObserver!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = categoryTableView.dequeueReusableCell(withIdentifier: "Cell") as! HealthTableViewCell
        let elem = elems[indexPath.row]
        cell.bindElement(element: elem)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return userIndex == 0
    }
    


}
