//
//  EventViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 27/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Eureka
import CoreLocation
import Toast_Swift
class EventViewController: FormViewController {
    var event = EventEntity()
    fileprivate func setinzerosdate(_ date: inout Date) {
        if (self.form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date) * -1
            let minutes = calendar.component(.minute, from: date) * -1
            date = calendar.date(byAdding: .hour, value: (hour ), to: date)!
            date = calendar.date(byAdding: .minute, value: (minutes), to: date)!
        }
        
    }
    
    fileprivate func setinenddate(_ date: inout Date) {
        if (self.form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date) * -1
            let minutes = calendar.component(.minute, from: date) * -1
            date = calendar.date(byAdding: .hour, value: (hour ), to: date)!
            date = calendar.date(byAdding: .minute, value: (minutes), to: date)!
            date = date.addingTimeInterval(TimeInterval(23*60))
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let addBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        self.tabBarController?.navigationItem.rightBarButtonItem = addBtn
        self.tabBarController?.navigationItem.title = "Nuevo Evento"
        form +++ Section("")
            <<< TextRow() { row in
                row.title = "Titúlo"
                row.placeholder = "Título"
                row.value = event.title
                }.onChange({ (row) in
                    self.event.title = row.value ?? ""
                })
            
            <<< TextRow(){ row in
                row.title = "Descripción"
                row.placeholder = "Descripción"
                row.value = event.details
                }.onChange({ (row) in
                    self.event.details = row.value
                })
            <<< LocationRow(){
                $0.title = "Ubicación"
                }.onChange({ (row) in
                    self.event.location = row.value
                    row.updateCell()
                })
            +++
            Section("Fecha y Hora")
            <<< SwitchRow() { row in
                row.title = "Todo el día"
                row.tag = "allDay"
                row.value = event.isAllDay ?? false
                }.onChange({ (row) in
                    self.event.isAllDay = row.value
                })
            <<<  DateTimeRow() { row in
                row.title = "Inicio"
                row.tag = "startDateTime"
                row.add(rule: RuleRequired())
                row.value = event.startdate == 0 ?  Date() : Date(event.startdate)
                }.onChange({ (row) in
                    self.event.startdate = (row.value?.toMillis())!
                    self.setinzerosdate(&row.value!)
                    if let eRow = self.form.rowBy(tag: "endDateTime") as? DateTimeRow {
                        eRow.updateCell()
                    }
                    
                }).cellUpdate({ (cell, row) in
                    if row.value == nil {
                        row.value = Date()
                    }
                    self.setinzerosdate(&row.value!)
                })
            <<<  DateTimeRow() { row in
                row.add(rule: RuleRequired())
                row.title = "Fin"
                row.tag = "endDateTime"
                 row.value = event.enddate == 0 ?  Date() : Date(event.enddate)
                }.onChange({ (row) in
                    self.event.enddate = (row.value?.toMillis())!
                    self.setinenddate(&row.value!)
                }).cellUpdate { (cell, row) in
                    let value  = (self.form.rowBy(tag: "startDateTime") as! DateTimeRow).value ?? Date()
                    self.setinenddate(&row.value!)
                    row.value = value
                    cell.datePicker.minimumDate = value
            }
            <<< PushRow<Frequency>() { row in
                row.title = "repeat"
                row.options = [.never,.daily,.weekly, .monthly, .year]
                row.value = self.event.repeatmodel?.frequency ?? .never
                
                row.selectorTitle = ""
                }.onChange({ (row) in
                    if row.isValid {
                        self.event.repeatmodel = repeatEntity()
                        self.event.repeatmodel?.frequency = row.value ?? .never
                        try! rManager.realm.write {
                            row.updateCell()
                        }
                    }
                }).onPresent({ (form, to) in
                    to.dismissOnSelection = true
                    to.dismissOnChange = false
                })
            <<< DateRow() { row in
                row.title = "Terminar"
                row.value = Date()
                row.hidden = Condition.function(["frequency"], { form in
                    
                    if let xrow = (form.rowBy(tag: "frequency") as? PushRow<Frequency>?)??.value {
                        let tag = xrow == .never
                        self.event.repeatmodel?.end = (row.value?.toMillis())!
                        if tag {
                            row.value = Date()
                        }
                        return tag
                    }
                    return false
                })
                }.onChange({ (row) in
                    self.event.repeatmodel?.end = (row.value?.toMillis())!
                }).cellUpdate { (cell, row) in
                    row.minimumDate = Date(self.event.enddate)
                }
            +++ Section()
            <<< PushRow<eventType>() { row in
                row.title = "Tipo"
                row.options = [.Default,.BirthDay,.Meet]
                row.value = self.event.eventtype
                row.tag = "type"
                row.selectorTitle = "Escogé un tipo de evento"
                }.onChange({ (row) in
                    if row.isValid {
                        self.event.eventtype = row.value ?? .Default
                        try! rManager.realm.write {
                            row.updateCell()
                        }
                    }
                }).onPresent({ (form, to) in
                    to.dismissOnSelection = true
                    to.dismissOnChange = false
                })
            <<< UsersRow(){
                $0.title = "Invitados"
                }.onChange({ (row) in
                    self.event.members.removeAll()
                    if let members = row.value?.list.map({ (uid) -> memberEventEntity in
                        return memberEventEntity(uid: uid)
                    }) {
                        self.event.members.append(objectsIn: members)
                    }
                    row.updateCell()
                })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    @objc func save() -> Void {
        let errors = form.validate()
        
        if errors.count == 0  {
            store.dispatch(EventSvc(.save(event: self.event)))
            event = EventEntity()
            tableView.reloadData()
        } else {
            let t = ToastStyle()
            self.view.makeToast("\(errors.description)", duration: 5.0, point: self.view.center, title: "Errores", image: nil, style: t, completion: nil)
        }
    
    }
    
    
}
