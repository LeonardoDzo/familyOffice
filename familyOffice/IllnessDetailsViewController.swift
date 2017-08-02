//
//  IllnessDetailsViewController.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/24/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import ReSwiftRouter

class IllnessDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var illness: Illness!
    
    var fields = [("Medicamento", ""), ("Dósis", ""), ("Más información", "")]
    var cellSelected = -1
    let user = store.state.UserState.user
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName:#colorLiteral(red: 0.2848778963, green: 0.2029544115, blue: 0.4734018445, alpha: 1)]
        self.navigationItem.title = "\(illness.name!)"
        
        let saveButton = UIBarButtonItem(title:"Editar", style: .plain, target: self, action: #selector(edit(sender:)))
        saveButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        
        //No sé cómo hacer esto mejor :s o es viernes por la tarde y me anda valiendo jajaja
        self.fields[0].1 = illness.medicine
        self.fields[1].1 = illness.dosage
        self.fields[2].1 = illness.moreInfo
        
        // Do any additional setup after loading the view.
    }
    
    func edit(sender: UIBarButtonItem){
        self.performSegue(withIdentifier: "editIllness", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editIllness"{
            let editViewController = segue.destination as! NewIllnessViewController
            editViewController.isEdit = true
            editViewController.illness = self.illness
        }
    }
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == cellSelected - 1 {
            cellSelected = -1
        }else{
            cellSelected = indexPath.row + 1
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fields.count*2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row/2)
        
        if indexPath.row % 2 == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderViewCell
            print(indexPath.row/2)
            print(self.fields[0].0)
            print(cell.hLabel)
            cell.hLabel.text = self.fields[indexPath.row/2].0
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "informationCell", for: indexPath) as! InformationViewCell
        cell.iLabel.text = self.fields[indexPath.row/2].1
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return UITableViewAutomaticDimension
        }else{
            if indexPath.row == cellSelected {
                return UITableViewAutomaticDimension
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func addObservers() -> Void {
        service.MEDICINE_SERVICE.initObservers(ref: "illnesses/\((user?.familyActive!))", actions: [ .childChanged])
    }
    
}

extension IllnessDetailsViewController: StoreSubscriber{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addObservers()
        
        store.subscribe(self) {
            subscription in
            subscription.IllnessState
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.state.IllnessState.status = .none
        store.unsubscribe(self)
        service.ILLNESS_SERVICE.removeHandles()
    }
    
    func newState(state: IllnessState) {
        self.navigationItem.title = illness.name!
        switch state.status{
        case .Finished(let t as Illness):
            self.view.hideToastActivity()
            illness = t
            store.state.IllnessState.status = .none
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        default:
            break
        }
    }
}