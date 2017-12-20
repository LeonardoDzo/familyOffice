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
class ContactsViewController: UIViewController, FamilyEBindable {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    typealias StoreSubscriberStateType = UserState
    var family : FamilyEntity!
    var users = [UserEntity]()
    var contacts : [CNContact] = []
    var members = [RealmString]()
    var phoneViews  = [(String,Bool)]()
    
    weak var contactDelegate : ContactsProtocol!
    let IndexPathOfFirstRow = NSIndexPath(row: 0, section: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBack()
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.add))
        self.navigationItem.rightBarButtonItem = add
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc override func back() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @objc func add() -> Void {
        store.dispatch(FamilyS(.update(family: self.family)))
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
                if let xphone = phone.value.value(forKey: "digits") as? String, xphone.count >= 10, xphone.suffix(10) != String(describing: getUser()?.phone){
                    self.addMember(phone: phone.value.value(forKey: "digits") as! String )
                }
                
            }
        }
    }
    func addMember(phone: String) -> Void {
        
        if !phoneViews.contains(where: {$0.0 == phone}) {
            phoneViews.append((phone,false))
        }
        
        if let user = rManager.realm.objects(UserEntity.self).filter("phone = %@", phone.suffix(10)).first {
            if !self.users.contains(where: {$0.id == user.id}), user.id != getUser()?.id {
                addUser(user)
            }
        }else{
            if var value = phoneViews.first(where: {$0.0 == phone}), !value.1, let index = phoneViews.index(where: {$0.0 == phone}){
                value.1 = true
                phoneViews[index] = value
                DispatchQueue.main.async {
                    store.dispatch(UserS(.getbyPhone(phone: phone)))
                }
            }
        }
    }
}
extension ContactsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellMember", for: indexPath) as! memberSelectedCollectionViewCell
        let uid = members[indexPath.row].value
        if let user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: uid) {
            cell.bind(userModel: user)
        }else{
            cell.nameLabel.text = "Cargando..."
            store.dispatch(UserS(.getbyId(uid: uid)))
        }
    
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let uid = members[indexPath.row].value
        if let index = family.members.index(where: {$0.value == uid}) {
            try! rManager.realm.write {
                family.members.remove(at: index)
                members = family.members.filter({$0.value != getUser()?.id})
            }
            
        }
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FamilyMemberTableViewCell
        let user = users[indexPath.row]
        if  family.members.contains(where: {$0.value == user.id}) {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        cell.bind(userModel: user)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        try! rManager.realm.write {
            if let index = family.members.index(where: {$0.value == user.id}){
                family.members.remove(at: index)
            }else{
                family.members.append(RealmString(value: user.id))
            }
            members = family.members.filter({$0.value != getUser()?.id})
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
        getContacts()
        showContacts()
        members = family.members.filter({$0.value != getUser()?.id})
        if users.count == 0 {
            let imageView = UIImageView()
            imageView.image = #imageLiteral(resourceName: "background_no_users")
            self.tableView.backgroundView = imageView
            imageView.contentMode = .scaleAspectFit
        }else {
            self.tableView.backgroundView = UIView()
        }
        self.tableView.tableFooterView = UIView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        store.unsubscribe(self)
    }
    fileprivate func addUser(_ user: UserEntity) {
        self.users.append(user)
        self.tableView.insertRows(at: [NSIndexPath(row: self.users.count-1, section: 0) as IndexPath], with: .fade)
    }
    
    func newState(state: UserState) {
        self.view.hideToastActivity()
        switch state.user {
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .Finished(let action as UserAction):
            switch action {
            case .getbyId(_):
                 self.tableView.reloadData()
                 self.collectionView.reloadData()
                break
            case .getbyPhone(let phone):
                self.addMember(phone: phone)
                break
            default:
                break
            }
        case .Finished(let user as UserEntity):
            addUser(user)
            break
        default:
            break
        }
    }
}
