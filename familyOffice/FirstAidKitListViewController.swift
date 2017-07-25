//
//  FirstAidKitListViewController.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/20/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Firebase

class FirstAidKitListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var medicines:[Medicine] = []
    let familyID = service.USER_SERVICE.users[0].familyActive!
    let settingLauncher = SettingLauncher()
    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName:#colorLiteral(red: 0.2848778963, green: 0.2029544115, blue: 0.4734018445, alpha: 1)]
        self.navigationItem.title = "Medicinas"
        
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
       self.performSegue(withIdentifier: "newMedicine", sender: self)
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
        self.performSegue(withIdentifier: "medicineDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.medicines.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "fakCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FirstAidKitCellView
        let medicine = self.medicines[indexPath.row]
        cell.nameLbl.text = medicine.name
        return cell
    }
    

    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "medicineDetails"{
            if let indexPath = self.tableView.indexPathForSelectedRow{
                let selectedMedicine = self.medicines[indexPath.row]
                let detailsViewController = segue.destination as! MedicineDetailsViewController
                detailsViewController.medicine = selectedMedicine
                
            }
        }
        searchController.isActive = false
    }

 

}

    //MARK: - StoreSubscriber

extension FirstAidKitListViewController: StoreSubscriber{
    
    override func viewWillAppear(_ animated: Bool) {
        service.MEDICINE_SERVICE.initObservers(ref: "medicines/\(familyID)", actions: [.childAdded, .childChanged, .childRemoved])
        
        store.subscribe(self){
            state in state.MedicineState
        }
    }
    
    func newState(state: MedicineState){
        medicines = state.medicines[familyID] ?? []
        print("---MEDICINAS---")
        print(medicines)
        print("---------------")
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.state.MedicineState.status = .none
        store.unsubscribe(self)
        service.MEDICINE_SERVICE.removeHandles()
    }
}

    //MARK := SearchController

extension FirstAidKitListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty{
            self.medicines = self.medicines.filter({$0.name.lowercased().contains(searchText.lowercased())})
        }else {
            self.medicines = store.state.MedicineState.medicines[familyID] ?? []
        }
        tableView.reloadData()
    }
}
