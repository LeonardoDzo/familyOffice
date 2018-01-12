//
//  FirstAidKitMainViewController.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazat on 1/3/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift

class FirstAidKitMainViewController: UIViewController {
//    var illnesses: [Illness] = []
    var illnesses: [IllnessEntity] = []
    var getIllnessUuid: String?
    let user = getUser()
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    var rowActions: [UITableViewRowAction]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        self.setStyle(.firstaidkit)
        self.title = "Botiquín"
        self.setupBack()
        
        tabBar.selectedItem = tabBar.items![0]
        tabBar.tintColor = #colorLiteral(red: 0.5490196078, green: 0.5294117647, blue: 0.7843137255, alpha: 1)
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.showEditing))
        
        self.navigationItem.rightBarButtonItem = editButton
        
        tableView.allowsSelectionDuringEditing = true
        rowActions = [
            UITableViewRowAction(style: .normal, title: "Editar", handler: {_, i in self.edit(i)}),
            UITableViewRowAction(style: .destructive, title: "Eliminar", handler: {_, i in self.remove(i)})
        ]

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showEditing(sender: UIBarButtonItem)
    {
        if(self.tableView.isEditing)
        {
            self.tableView.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Editar"
        }
        else
        {
            self.tableView.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Listo"
        }
    }
    
    func handleNew(){
        let ctrl = NewIllnessFormController()
        ctrl.entity = IllnessEntity()
        ctrl.action = .Create
        show(ctrl, sender: self)
    }
    
    func edit(_ indexPath: IndexPath) {
        print("??")
        let ctrl = NewIllnessFormController()
        ctrl.action = .Update
        ctrl.entity = illnesses[indexPath.row]
        show(ctrl, sender: self)
        tableView.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItem?.title = "Edit"
    }
    
    func remove(_ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Eliminar", message: "¿Estás seguro que deseas eliminar \(self.illnesses[indexPath.row].name)?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive, handler: { (action) in
            let entity = self.illnesses.remove(at: indexPath.row)
            store.dispatch(removeIllnessAction(illness: entity, uuid: UUID().uuidString))
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func setIllnesses() {
        let tag = (self.tabBar.selectedItem?.tag)!
        illnesses = tag <= 0 ? rManager.realm.objects(IllnessEntity.self).filter("family == '\((self.user?.familyActive)!)'").map({$0}) : rManager.realm.objects(IllnessEntity.self).filter("family == '\((self.user?.familyActive)!)'").map({$0}).filter({$0.type == tag - 1})
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details"{
            if let illness = sender as? IllnessEntity {
                let vc = segue.destination as! FirstAidKitDetailsViewController
                vc.illness = illness
            }
        }
    }
 

}

extension FirstAidKitMainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return illnesses.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            edit(indexPath)
        } else {
            self.performSegue(withIdentifier: "details", sender: self.illnesses[indexPath.row] )
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return tableView.isEditing ? rowActions : [rowActions[1]]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "firstaidkitCell") as! FirstAidKitCell
        let illness = self.illnesses[indexPath.row]
        
        if illness.type == 0 {
            cell.IndicatorView.backgroundColor = #colorLiteral(red: 0.7685001586, green: 0.00719451062, blue: 0, alpha: 1)
        } else {
            cell.IndicatorView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
        
        
        cell.titleLbl.text = illness.name
        cell.descLbl.text = "\(illness.medicine), \(illness.dosage)"
        
//        cell.title.text = illness.name
//        cell.subtitle.text = illness.medicine
//        cell.desc.text = "Descripción, bla bla bla... wuuuuu"
        
        return cell
    }
}

extension FirstAidKitMainViewController: StoreSubscriber {
    
    typealias StoreSubscriberStateType = RequestState
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self){
            subcription in
            subcription.select { state in state.requestState }
        }
        getIllnessUuid = UUID().uuidString
        store.dispatch(getIllnessesAction(byFamily: (self.user?.familyActive)!, uuid: getIllnessUuid!))
        tableView.reloadData()
    }
    
    func newState(state: RequestState) {
//        let backgroundnoevents = UIImageView(frame: self.view.frame)
//        backgroundnoevents.tag = 100
//        illnesses = state.illnesses[(user?.familyActive)!] ?? []
//        print(state.status)
//        if illnesses.count == 0 {
//            backgroundnoevents.image = #imageLiteral(resourceName: "no-insurances")
//            self.tableView.backgroundView = backgroundnoevents
//            backgroundnoevents.contentMode = .center
//        } else {
//            self.tableView.backgroundView = nil
//        }
//        tableView.reloadData()
        guard let iReqId = getIllnessUuid else {
            return
        }
        switch state.requests[iReqId] {
            case .loading?:
                break
            case .Failed(_)?:
                break
            case .finished?:
                illnesses = rManager.realm.objects(IllnessEntity.self)
                    .filter("family == '\((self.user?.familyActive)!)'")
                    .map({$0})
                self.tableView.reloadData()
            default:
                break;
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
}

extension FirstAidKitMainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            illnesses = illnesses.filter({$0.name.lowercased().contains(searchBar.text!.lowercased()) || $0.medicine.lowercased().contains(searchBar.text!.lowercased())})
        }else{
            setIllnesses()
        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            setIllnesses()
        }else{
            setIllnesses()
            illnesses = illnesses.filter({$0.name.lowercased().contains(searchBar.text!.lowercased()) || $0.medicine.lowercased().contains(searchBar.text!.lowercased())})
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setIllnesses()
        tableView.reloadData()
    }
}

extension FirstAidKitMainViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item.tag)
        switch (item.tag){
        case 0:
            self.illnesses = rManager.realm.objects(IllnessEntity.self).filter("family == '\((self.user?.familyActive)!)'").map({$0})
            break
        case 1, 2:
            self.illnesses = rManager.realm.objects(IllnessEntity.self).filter("family == '\((self.user?.familyActive)!)'").map({$0}).filter({$0.type == item.tag - 1})
            break
        case 3:
            self.handleNew()
            tabBar.selectedItem = tabBar.items![0]
        default: break
        }
        self.tableView.reloadData()
    }
}
