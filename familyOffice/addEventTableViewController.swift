//
//  addEventTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 29/05/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import ReSwift
protocol ShareEvent: class {
    var event: Event! {get set}
}
extension ShareEvent {
    func bind(_ event: Event) -> Void {
        self.event = event
    }
}

class addEventTableViewController: UITableViewController, EventBindable, ShareEvent {
    @IBOutlet weak var memberCountLbl: UILabel!
    var event: Event!
    var startActivate = false
    var endActivate = false
    @IBOutlet weak var titleTxtField: UITextField!
    @IBOutlet weak var endDatepicker: UIDatePicker!
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var endDateLbl: UILabel!
    @IBOutlet weak var startDatepicker: UIDatePicker!
    @IBOutlet weak var ubicationLabel: UITextField!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var endRepeat: UILabel!
    @IBOutlet weak var descriptionTxtField: UITextField!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var allDaySwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        let addButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        navigationItem.rightBarButtonItems = [addButton]
    }
    override func viewWillAppear(_ animated: Bool) {
        self.bind()
        let date = Date(timeIntervalSince1970: TimeInterval(event.date/1000))
        endDatepicker.minimumDate = date
        tableView.reloadData()
    }
    
    @IBAction func handleChangeAllDay(_ sender: UISwitch) {
        event.isAllDay = sender.isOn
        if sender.isOn {
            endDatepicker.datePickerMode = .date
            startDatepicker.datePickerMode = .date
        }else{
            endDatepicker.datePickerMode = .dateAndTime
            startDatepicker.datePickerMode = .dateAndTime
        }
        
        self.bind()
    }
    
    @IBAction func handleChangeSDate(_ sender: UIDatePicker) {
        var formatter: DateFormatter!
        if allDaySwitch.isOn {
            formatter = .dayMonthAndYear
        }else{
            formatter = .dayMonthYearHourMinute
        }
        
        let date = Date(string: sender.date.string(with: formatter), formatter: formatter)
        endDatepicker.minimumDate = date
        event.date = date?.toMillis()
        if event.endDate < event.date {
            event.endDate = date?.toMillis()
        }
        self.bind()
    }
    
    
    @IBAction func handleChangeEDate(_ sender: UIDatePicker) {
        var formatter: DateFormatter!
        if allDaySwitch.isOn {
            formatter = .dayMonthAndYear
        }else{
            formatter = .dayMonthYearHourMinute
        }
        
        let date = Date(string: sender.date.string(with: formatter), formatter: formatter)
        event.endDate = date?.toMillis()
        endDateLbl.text = date?.string(with: formatter)
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
            if indexPath.row == 6 && event.repeatmodel.frequency == .never {
                return 0.0
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
        preSave()
        if let destination = segue.identifier {
            switch destination {
            case "inviteSegue":
                if let navController = segue.destination as? UINavigationController {
                    if let vc = navController.topViewController as? MembersTableViewController {
                        vc.shareEvent = self
                    }
                }
                break
            case "mapSegue":
//                let viewController = segue.destination as! MapViewController
//                viewController.shareEvent = self
                break
            case "repeatSegue":
                let viewController = segue.destination as! repeatEventTableViewController
                viewController.shareEvent = self
                break
            case "endRSegue":
                let viewController = segue.destination as! EndRepeatEventTableViewController
                viewController.shareEvent = self
                break
            case "typeSegue":
                let viewController = segue.destination as! Type_EventTableViewController
                viewController.shareEvent = self
                break
            default:
                break
            }
        }
    }
    
}
extension addEventTableViewController {
    func dismissPopover() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func update()  {
        guard validation() else {
            return
        }
        //update
    }
    @objc func save(){
        preSave()
        guard validation() else {
            return
        }
    }
    func validation() -> Bool{
        
        guard (!event.title.isEmpty) else {
            return false
        }
        return true
   }
    
    func preSave(){
        event.title = titleTxtField.text
        event.description = descriptionTxtField.text
    }
}

