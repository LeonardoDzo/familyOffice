//
//  GoalTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 12/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift

protocol Segue: class {
    func selected(_ segue: String, sender: Any?) -> Void
}

class GoalTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    var types = [("Deportivo","sports-wide"),("Religión","religion-wide"),("Escolar","school-wide"),("Negocios","business-wide"),("Alimentación","nutrition-wide"),("Salud","health-wide")]
    typealias StoreSubscriberStateType = GoalState
    
    var myGoals = [Goal]()
    var user = store.state.UserState.user
    var cellSelected = -1
    lazy var settingLauncher : SettingLauncher = {
        let launcher = SettingLauncher()
        launcher.handleFamily = self
        return launcher
    }()
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items?[0]
        self.tableView.formatView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let data = getDataByIndex(indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSection", for: indexPath) as!  GoalSectionTableViewCell
            let obj = types[indexPath.row/2]
            cell.backgroundImage.image  = UIImage(named: obj.1)
            let name = data.count > 0 ? " (\(data.filter({$0.done ?? false }).count)/\(data.count))" : " (No existen)"
            cell.nameLbl.text = obj.0 + name
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellData", for: indexPath) as! GoalDataofSectionTableViewCell
        cell.data = getDataByIndex(indexPath)
        cell.segueDelegate = self
        cell.tableView.reloadData()
        cell.chageHeight()
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return tableView.frame.height/6 - 11
        }else{
            if indexPath.row == cellSelected {
                let heigtht = getDataByIndex(indexPath).count * 44
                return CGFloat(heigtht)
            }
            return 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == cellSelected - 1 {
            cellSelected = -1
        }else{
             cellSelected = indexPath.row + 1
        }
       tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }

}
extension GoalTableViewController: StoreSubscriber, Segue, HandleFamilySelected {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addObservers()
        if let family = store.state.FamilyState.families.family(fid: (store.state.UserState.user?.familyActive)!){
            service.USER_SVC.selectFamily(family: family)
        }
        selectFamily()
        store.subscribe(self) {
            subcription in
            subcription.select { state in state.GoalsState }
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.state.GoalsState.status = .none
        store.unsubscribe(self)
        service.GOAL_SERVICE.removeHandles()
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSegue" {
            let vc = segue.destination as! AddGoalViewController
            let goal :Goal!
            
            goal = Goal()
            if tabBar.selectedItem?.tag == 1 {
                goal.type = 1
            }
            vc.bind(goal: goal )
            
            
        }else if segue.identifier == "infoSegue" {
            let vc = segue.destination as! GoalViewController
            if sender is Goal {
                vc.bind(goal: sender as! Goal)
            }
        }else if segue.identifier == "detailSegue" {
            let vc = segue.destination as! GoalHistoryByUserViewController
            if sender is Goal {
                vc.bind(goal: sender as! Goal)
                vc.user = user
            }
        }
    }
    
    func configuration() -> Void {
        addObservers()
        newState(state: store.state.GoalsState)
        tableView.reloadData()
    }
    func addObservers() -> Void {
        if tabBar.selectedItem?.tag == 0 {
            service.GOAL_SERVICE.type = .Individual
            let id = store.state.UserState.user?.id!
            service.GOAL_SERVICE.initObserves(ref: "goals/\(id!)", actions: [.childAdded, .childRemoved, .childChanged])
        }else{
            service.GOAL_SERVICE.type = .Familiar
            service.GOAL_SERVICE.initObserves(ref: "goals/\((user?.familyActive!)!)", actions: [.childAdded, .childRemoved, .childChanged])
        }
    }
    func newState(state: GoalState) {
        user = store.state.UserState.user
        if tabBar.selectedItem?.tag == 0 {
            myGoals = state.goals[(user?.id)!] ?? []

        }else{
            myGoals = state.goals[(user?.familyActive!)!] ?? []
        }
        tableView.reloadData()
    }
    func selectFamily() -> Void {
        if let family = store.state.FamilyState.families.family(fid: (store.state.UserState.user?.familyActive)!){
            self.navigationItem.title = family.name
        }
        configuration()
    }
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        configuration()
    }
    func selected(_ segue: String, sender: Any?) {
        self.performSegue(withIdentifier: segue, sender: sender)
    }
}
extension GoalTableViewController {
    func getDataByIndex(_ indexPath: IndexPath) -> [Goal] {
        let index = indexPath.row % 2 == 0 || indexPath.row == 0 ? indexPath.row/2 : (indexPath.row-1)/2
        return myGoals.filter({$0.category == index})
    }
    func setupNavBar(){
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleNew))
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_more_button"), style: .plain, target: self, action:  #selector(self.handleMore))
 
        self.navigationItem.rightBarButtonItems = [moreButton, addButton]
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
    }
    @objc func handleMore(_ sender: Any) {
        settingLauncher.showSetting()
    }
    @objc func handleNew() -> Void {
        self.performSegue(withIdentifier: "addSegue", sender: nil)
    }
    @objc func back() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
}
