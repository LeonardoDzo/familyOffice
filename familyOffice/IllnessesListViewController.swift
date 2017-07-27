//
//  IllnessesListViewController.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/20/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Firebase

class IllnessesListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var illnesses:[Illness] = []
    let familyID = store.state.UserState.user?.familyActive!
    
    let searchController = UISearchController(searchResultsController: nil)
    var settingLauncher = SettingLauncher()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName:#colorLiteral(red: 0.2848778963, green: 0.2029544115, blue: 0.4734018445, alpha: 1)]
        self.navigationItem.title = "Enfermedades"
        
        tableView.tableHeaderView = searchController.searchBar
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleNew))
        addButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_more_button"), style: .plain, target: self, action:  #selector(self.handleMore(_:)))
        moreButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        
        self.navigationItem.rightBarButtonItems = [moreButton,addButton]
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Botones
    func handleNew() -> Void {
        self.performSegue(withIdentifier: "newIllness", sender: self)
    }
    
    func handleMore(_ sender: Any){
        settingLauncher.showSetting()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "illnessDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.illnesses.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "fakCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FirstAidKitCellView
        let illness = self.illnesses[indexPath.row]
        cell.nameLbl.text = illness.name
        return cell
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "illnessDetails"{
            if let indexPath = self.tableView.indexPathForSelectedRow{
                let selectedIllness = self.illnesses[indexPath.row]
                let detailsViewController = segue.destination as! IllnessDetailsViewController
                detailsViewController.illness = selectedIllness
                
            }
        }
        searchController.isActive = false
    }
    
}

//MARK: - StoreSubscriber

extension IllnessesListViewController: StoreSubscriber{
    typealias StoreSubscriberStateType = IllnessState
    
    override func viewWillAppear(_ animated: Bool) {
        service.ILLNESS_SERVICE.initObservers(ref: "illnesses/\(familyID!)", actions: [.childAdded, .childChanged, .childRemoved])
        
        store.subscribe(self){
            state in state.IllnessState
        }
    }
    
    func newState(state: IllnessState){
        illnesses = state.illnesses[familyID!] ?? []
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.state.IllnessState.status = .none
        store.unsubscribe(self)
        service.ILLNESS_SERVICE.removeHandles()
    }
}

//MARK := SearchController

extension IllnessesListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty{
            self.illnesses = self.illnesses.filter({$0.name.lowercased().contains(searchText.lowercased())})
        }else {
            self.illnesses = store.state.IllnessState.illnesses[familyID!] ?? []
        }
        tableView.reloadData()
    }
}
