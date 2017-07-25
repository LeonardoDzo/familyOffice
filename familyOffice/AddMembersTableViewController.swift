//
//  AddMembersTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 08/02/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class AddMembersTableViewController: UITableViewController {
    let center = NotificationCenter.default
    var contacts : [CNContact] = []
    var selected : [User] = []
    var users : [User] = []
    var family : Family!
    var itemCount = 0
    var localeChangeObserver : NSObjectProtocol!
    let IndexPathOfFirstRow = NSIndexPath(row: 0, section: 0)
    var firstCell : SelectedTableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.plain, target: self, action:#selector(save(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.3137395978, green: 0.1694342792, blue: 0.5204931498, alpha: 1)]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        }else{
            return users.count
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? SelectedTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        firstCell = tableViewCell
    }
    override func viewWillAppear(_ animated: Bool) {
        users = []
        if let index = service.FAMILY_SERVICE.families.index(where: {$0.id == self.family.id}) {
            self.family = service.FAMILY_SERVICE.families[index]
        }
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
        let mainQueue = OperationQueue.main
        self.localeChangeObserver =  center.addObserver(forName: notCenter.USER_NOTIFICATION, object: nil, queue: mainQueue){user in
            if let user : User = user.object as? User {
                self.addMember(phone: user.phone)
            }
        }
        getContacts()
        showContacts()   
    }
    override func viewWillDisappear(_ animated: Bool) {
        users = []
        selected = []
        center.removeObserver(self.localeChangeObserver)
        Constants.FirDatabase.REF_USERS.removeAllObservers()
        super.viewDidDisappear(animated)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Cell for selected members
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedMembers", for: indexPath) as! SelectedTableViewCell
            return cell
        }
        
        //Conctacts
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FamilyMemberTableViewCell
        cell.bind(userModel: user)
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if selected.count == 0 {
                return 0.0
            }
            return 100.0
        }
        return 84.0
    }
    func getContacts() -> Void {
        let store = CNContactStore()
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor])
        try! store.enumerateContacts(with: fetchRequest) { contact, stop in
            if contact.phoneNumbers.count > 0 {
                self.contacts.append(contact)
            }
        }
    }
    func showContacts() -> Void {
        self.users = []
        for item in contacts {
            for phone in item.phoneNumbers {
                addMember(phone: phone.value.value(forKey: "digits") as! String )
            }
        }
    }
    func addMember(phone: String) -> Void {
        
        if let user = service.USER_SERVICE.users.filter({$0.phone == phone}).first {
            if !self.users.contains(where: {$0.id == user.id}) && !self.family.members.contains(where: {$0 == user.id}){
                self.users.append(user)
                self.tableView.insertRows(at: [NSIndexPath(row: self.users.count-1, section: 1) as IndexPath], with: .fade)
            }
        }else{
            service.USER_SERVICE.getUser(phone: phone)
        }
    }
    func save(sender: UIBarButtonItem) -> Void {
        self.view.makeToastActivity(.center)
        for user in selected {
            service.FAMILY_SERVICE.addMember(uid: user.id, fid: family.id)
        }
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
}
