//
//  ContactsViewController.swift
//  familyOffice
//
//  Created by miguel reina on 26/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import ReSwift
class contactTableViewController: UITableViewController, StoreSubscriber{
    var contacts = [Contact]()
    let settingLauncher = SettingLauncher()
    typealias StoreSubscriberStateType = ContactState
    let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        setupNavBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self){
            state in
            state.ContactState
        }
        configureObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        service.CONTACT_SVC.removeHandles()
        store.state.ContactState.status = .none
        
    }
    func setupNavBar(){
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.add))
        addButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_more_button"), style: .plain, target: self, action:  #selector(self.handleMore))
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Home"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.rightBarButtonItems = [moreButton, addButton]
        self.navigationItem.leftBarButtonItem = backButton
        
    }
    func configureObservers(){
        let ref = "contacts/\((store.state.UserState.user?.familyActive)!)/"
        service.CONTACT_SVC.initObserves(ref: ref, actions: [.childAdded,.childChanged,.childRemoved])
    }
    func back() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    func add() {
        
        performSegue(withIdentifier: "addContactSegue", sender: self)
    }
    func handleMore(_ sender: Any) {
        settingLauncher.showSetting()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchController.isActive = false
        if segue.identifier == "addContactSegue" {
            let vc = segue.destination as! addContactTableViewController
            let contact :Contact!
            if sender is Contact {
                contact = sender as? Contact
                vc.bind(contact: contact)
            }else{
                contact = Contact(name: "", phone: "", job: "", address: "", webpage: "", email: "")
                vc.bind(contact: contact )
            }
            
        }else {
            let vc = segue.destination as! InfoContactViewController
            let contact :Contact!
            if sender is Contact {
                contact = sender as? Contact
                vc.bind(contact: contact)
            }
        }
    }
    func selectfamily(fid:String){
        if let family = store.state.FamilyState.families.first(where: {$0.id == fid}){
             self.navigationItem.title = "Contactos de \(family.name!)"
        }
    }
    func newState(state: ContactState) {
        let user = store.state.UserState.user
        selectfamily(fid: (user?.familyActive)!)
        contacts = state.contacts[(user?.familyActive)!] ?? []
        configureObservers()
        tableView.reloadData()
    }
    
    
}
extension contactTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! contactTableViewCell
        
        cell.bind(contact: contacts[indexPath.row])
        return cell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        performSegue(withIdentifier: "infoSegue", sender: contact)
    }
}

extension contactTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let user = store.state.UserState.user
        if let searchText = searchController.searchBar.text,  !searchText.isEmpty {
            self.contacts = self.contacts.filter({$0.name.lowercased().contains(searchText.lowercased())  || $0.job.lowercased().contains(searchText.lowercased())})
        }else{
            self.contacts = store.state.ContactState.contacts[(user?.familyActive)!] ?? []
        }
        tableView.reloadData()
    }
}
