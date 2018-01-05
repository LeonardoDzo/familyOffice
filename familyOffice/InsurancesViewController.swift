//
//  InsurancesViewController.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazat on 12/18/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift

class InsurancesViewController: UIViewController {
    
    var insurances: [Insurance] = []
    var filter: String!
    let user = getUser()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(filter)
        
        switch filter {
        case "car":
            self.title = "Carros"
            break
        case "home":
            self.title = "Hogar"
            break
        case "medical":
            self.title = "Médicos"
            break
        case "life":
            self.title = "Vida"
            break
        default: break
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "policyPreview" {
            let insurance = sender as! Insurance
            let vc = segue.destination as! InsurancesPolicyViewController
            vc.insurance = insurance
        }
    }
 

}

extension InsurancesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.insurances.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if insurances[indexPath.row].downloadUrl != "" {
            self.performSegue(withIdentifier: "policyPreview", sender: self.insurances[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "insuranceCell", for: indexPath) as! InsuranceCell
        let insurance = self.insurances[indexPath.row]
        cell.nameLbl.text = insurance.name
        cell.policyLbl.text = "Póliza: \(insurance.policy!)"
        cell.phoneTextView.text = "\(insurance.telephone!)"
        
        cell.attachment.image =  cell.attachment.image?.imageWithColor(tintColor: #colorLiteral(red: 0.07450980392, green: 0.3215686275, blue: 0.2039215686, alpha: 1))
        cell.attachment.isHidden = insurance.downloadUrl == ""
        
        return cell
    }
}

extension InsurancesViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = InsuranceState
    override func viewWillAppear(_ animated: Bool) {
        print((user?.id)!)
        service.INSURANCE_SERVICE.initObservers(ref: "insurances/\((user?.id)!)", actions: [.childAdded, .childChanged, .childRemoved])
        
        store.subscribe(self){
            subcription in
            subcription.select { state in state.insuranceState }
        }
    }
    
    func newState(state: InsuranceState) {
        let backgroundnoevents = UIImageView(frame: self.view.frame)
        backgroundnoevents.tag = 100
        insurances = state.insurances[(user?.id)!]?.filter({$0.type == self.filter}) ?? []
        print(state.status)
        if insurances.count == 0 {
            backgroundnoevents.image = #imageLiteral(resourceName: "no-insurances")
            self.tableView.backgroundView = backgroundnoevents
            backgroundnoevents.contentMode = .center
        } else {
            self.tableView.backgroundView = nil
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.state.insuranceState.status = .none
        store.unsubscribe(self)
        service.INSURANCE_SERVICE.removeHandles()
    }
}
