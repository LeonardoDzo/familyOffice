//
//  MembersTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/05/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
class MembersTableViewController: UITableViewController,UISearchResultsUpdating {
    var users : [User]! = []
    var membersSelected: [memberEvent]! = []
    weak var shareEvent : ShareEvent?
    let searchController = UISearchController(searchResultsController: nil)
    var filtered:[User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    }
    
    @IBAction func handleDone(_ sender: UIBarButtonItem) {
        shareEvent?.event.members = membersSelected
        dismissPopover()
    }
    
    @IBAction func handleCancel(_ sender: UIBarButtonItem) {
        dismissPopover()
    }
    
    func dismissPopover() {
        self.dismiss(animated: true, completion: nil)
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive && !(searchController.searchBar.text?.isEmpty)! {
            return filtered.count
        }
        return self.users.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.getUserByIndexPath(indexPath)
        if !contains((user?.id)!) {
            membersSelected.append(memberEvent(id: (user?.id)!, reminder: "none", status: "Pending"))
        }else if let index = membersSelected.index(where: {$0.id == user?.id}){
            membersSelected.remove(at: index)
        }
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filtered = self.users.filter { user in
                return user.name.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! memberEventTableViewCell
        var user : User!
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filtered[indexPath.row]
        } else {
            user = self.users[indexPath.row]
        }
        
        cell.bind(userModel: user)
        
        if contains(user.id){
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        // Configure the cell...
        
        return cell
    }
    func getUserByIndexPath(_ indexPath: IndexPath) -> User? {
        var user : User!
        if searchController.isActive && !(searchController.searchBar.text?.isEmpty)! {
            user = filtered[indexPath.row]
        }else{
            user = users[indexPath.row]
        }
        return user
    }
    func contains(_ id: String) -> Bool {
        if (membersSelected.contains(where: {$0.id == id})){
            return true
        }else{
            return false
        }
    }
   
}
extension MembersTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = UserState
    override func viewWillAppear(_ animated: Bool) {
    
        store.subscribe(self){
            subcription in
            subcription.select { state in state.UserState }
        }
        
    }
    func newState(state: UserState) {
        self.users = state.getUsers()
        self.tableView.reloadData()
    }
    
}
