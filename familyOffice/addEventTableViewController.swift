//
//  addEventTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 29/05/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

protocol ShareEvent: class {
    var event: Event! {get set}
}
extension ShareEvent {
    func bind(_ event: Event) -> Void {
        self.event = event
    }
}

class addEventTableViewController: UITableViewController, ShareEvent {
    @IBOutlet weak var numberSelected: UILabel!
    var event: Event!
    var startActivate = false
    var endActivate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
    }
    override func viewWillAppear(_ animated: Bool) {
        self.bind(event!)
       
        if !event.id.isEmpty {
            
        }else{
          
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if indexPath.row == 2 || indexPath.row == 4 {
                if startActivate && indexPath.row == 2 {
                    return 120.0
                }else if endActivate && indexPath.row == 4{
                    return 120.0
                }else{
                    return 0.0
                }
              
            }
        }
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                startActivate = !startActivate
                
            }else if indexPath.row == 3{
                endActivate = !endActivate
            }
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.identifier {
            switch destination {
            case "inviteSegue":
                if let navController = segue.destination as? UINavigationController {
                    
                    if let vc = navController.topViewController as? MembersTableViewController {
                         vc.shareEvent = self
                        
                    }
                    
                }
                break
            default:
                break
            }
        }
    }
   
}
extension addEventTableViewController {
    func update()  {
        guard validation() else {
            return
        }
    Constants.Services.EVENT_SERVICE.update("events/\(event.id!)", value: event.toDictionary() as! [AnyHashable : Any], callback: { response in
            if response is String {
                //Actualización local del evento que se acaba de modificar
                if let index = Constants.Services.EVENT_SERVICE.events.index(where: {$0.id == self.event.id}){
                    Constants.Services.EVENT_SERVICE.events[index] = self.event
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    func saveEvent(){
        guard validation() else {
            return
        }
        
        let key = Constants.FirDatabase.REF.childByAutoId().key
        event.id = key
        
        event.members.append(memberEvent(id: Constants.Services.USER_SERVICE.users[0].id, reminder: event.reminder!, status: "Aceptada"))
        Constants.Services.EVENT_SERVICE.insert("events/\(key)", value: event.toDictionary(), callback: { response in
            if response is String {
                Constants.Services.EVENT_SERVICE.events.append(self.event)
                _ = self.navigationController?.popViewController(animated: true)
            }
        })
    }
    func validation() -> Bool{
 
        guard (!event.title.isEmpty) else {
           
            return false
        }
        
        guard (!event.date.isEmpty) else {
       
            return false
        }
        guard (!event.endDate.isEmpty) else {
          
            return false
        }
        
        return true
    }
}