//
//  ContactsViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 19/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import ReSwift
class ContactsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    typealias StoreSubscriberStateType = UserState
    let family : FamilyEntitie! = nil
    var users = [UserEntitie]()
    var selected = [UserEntitie]()
    var contacts : [CNContact] = []
    weak var contactDelegate : ContactsProtocol!
    let IndexPathOfFirstRow = NSIndexPath(row: 0, section: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "DownChevron"), style: .plain, target: self, action: #selector(self.back))
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.add))
        self.navigationItem.leftBarButtonItem = back
        self.navigationItem.rightBarButtonItem = add
        self.tableView.formatView()
        self.collectionView.formatView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func back() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @objc func add() -> Void {
        contactDelegate.selected(users: selected)
        back()
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
                if phone.value.value(forKey: "digits") as? String  != getUser()?.phone{
                    self.addMember(phone: phone.value.value(forKey: "digits") as! String )
                }
                
            }
        }
    }
    func addMember(phone: String) -> Void {
        
        if let user = rManager.realm.objects(UserEntitie.self).filter("phone = %@", phone).first {
            if !self.users.contains(where: {$0.id == user.id}) {
                self.users.append(user)
                self.tableView.insertRows(at: [NSIndexPath(row: self.users.count-1, section: 0) as IndexPath], with: .fade)
            }
        }else{
            let action = UserS()
            action.action = .getbyPhone(phone: phone)
            store.dispatch(action)
        }
    }
}
extension ContactsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selected.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellMember", for: indexPath) as! memberSelectedCollectionViewCell
        let user = selected[indexPath.row]
        cell.bind(userModel: user)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        self.tableView.reloadData()
    }
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FamilyMemberTableViewCell
   
        if selected.contains(where: {$0.id == user.id}) {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        if let index = selected.index(where: {$0.id == user.id}){
            selected.remove(at: index)
        }else{
            selected.append(user)
        }
        self.collectionView.reloadData()
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}
extension ContactsViewController: StoreSubscriber {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        store.subscribe(self) {
            subcription in
            subcription.select { state in state.UserState }
        }
        selected = contactDelegate.users
        getContacts()
        showContacts()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        store.unsubscribe(self)
    }
    func newState(state: UserState) {
        self.view.hideToastActivity()
        switch state.users {
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .Finished(let action as UserAction):
            if case UserAction.getbyPhone(_) = action {
                self.tableView.reloadData()
            }
            break
        default:
            break
        }
    }
}
