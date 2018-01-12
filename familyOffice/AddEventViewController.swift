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
class EventViewController: FormViewController, EventEBindable {
    var event: EventEntity! = EventEntity()
    
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
    
    fileprivate func formChanged(_ tag: String) {
        try! rManager.realm.write {
            let valuesDictionary = form.values()
            let value = valuesDictionary[tag]
            switch tag {
                case "title":
                    self.event.title = value as! String
                    break
                case "details":
                    self.event.details = value as! String
                    break
                case "location":
                    self.event.location = value as? Location ?? nil
                    break
                case "title":
                    title = value as? String
                    break
                
                default:
                    break
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        form +++ Section("")
            <<< TextRow() { row in
                row.title = "Titúlo"
                row.placeholder = "Título"
                row.tag = "title"
                row.value = event.title
                }.onChange({ (row) in
                    self.formChanged(row.tag!)
                })
            
            <<< TextRow(){ row in
                row.title = "Descripción"
                row.placeholder = "Descripción"
                row.value = event.details
                row.tag = "details"
                }.onChange({ (row) in
                    self.formChanged(row.tag!)
                })
            <<< LocationRow(){
                $0.title = "Ubicación"
                $0.tag = "location"
                $0.value = self.event.location
                }.onChange({ (row) in
                    self.formChanged(row.tag!)
                    row.updateCell()
                })
            +++
            Section("Fecha y Hora")
            <<< SwitchRow() { row in
                row.title = "Todo el día"
                row.tag = "allDay"
                row.value = event.isAllDay ?? false
                }.onChange({ (row) in
                    self.formChanged(row.tag!)
                })
            <<<  DateTimeRow() { row in
                row.title = "Inicio"
                row.tag = "startDateTime"
                row.add(rule: RuleRequired())
                row.value = event.startdate == 0 ?  Date() : Date(event.startdate)
                row.hidden = Condition.function(["allDay"], { form in
                    return ((form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false)
                })
                }.onChange({ (row) in
                    self.formChanged()
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
                row.hidden = Condition.function(["allDay"], { form in
                    return ((form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false)
                })
                row.value = event.enddate == 0 ?  Date() : Date(event.enddate)
                }.onChange({ (row) in
                    self.formChanged()
                    self.setinenddate(&row.value!)
                }).cellUpdate { (cell, row) in
                    
                    let value  = (self.form.rowBy(tag: "startDateTime") as! DateTimeRow).value ?? Date()
                    
                    self.setinenddate(&row.value!)
                    if row.value == nil {
                        row.value = value
                    }
                    cell.datePicker.minimumDate = value
            }
            <<<  DateRow() { row in
                row.title = "Inicio"
                row.tag = "startDate"
                row.add(rule: RuleRequired())
                row.hidden = Condition.function(["allDay"], { form in
                    return !((form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false)
                })
                row.value = event.startdate == 0 ?  Date() : Date(event.startdate)
                }.onChange({ (row) in
                    self.formChanged()
                    self.setinzerosdate(&row.value!)
                    if let eRow = self.form.rowBy(tag: "endDate") as? DateTimeRow {
                        eRow.updateCell()
                    }
                    
                }).cellUpdate({ (cell, row) in
                    if row.value == nil {
                        row.value = Date()
                    }
                    self.setinzerosdate(&row.value!)
                })
            <<<  DateRow() { row in
                row.add(rule: RuleRequired())
                row.title = "Fin"
                row.hidden = Condition.function(["allDay"], { form in
                    return !((form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false)
                })
                row.tag = "endDate"
                row.value = event.enddate == 0 ?  Date() : Date(event.enddate)
                }.onChange({ (row) in
                    self.formChanged()
                    self.setinenddate(&row.value!)
                }).cellUpdate { (cell, row) in
                    
                    let value  = (self.form.rowBy(tag: "startDate") as! DateRow).value ?? Date()
                    
                    self.setinenddate(&row.value!)
                    if row.value == nil {
                        row.value = value
                    }
                    cell.datePicker.minimumDate = value
            }
            <<< PushRow<Frequency>() { row in
                row.title = "Repetir"
                row.options = [.never,.daily,.weekly, .monthly, .year]
                row.value = self.event.repeatmodel?.frequency ?? .never
                row.tag = "frequency"
                row.selectorTitle = ""
                
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                }.onChange({ (row) in
                    if row.isValid {
                        self.formChanged()
                        row.updateCell()
                    }
                }).onPresent({ (form, to) in
                    to.navigationController?.setNavigationBarHidden(false, animated: true)
                    to.dismissOnSelection = true
                    to.dismissOnChange = false
                })
            <<< DateRow() { row in
                row.title = "Terminar"
                row.value = Date()
                row.tag = "endRepeat"
                row.hidden = Condition.function(["frequency"], { form in
                    
                    if let xrow = (form.rowBy(tag: "frequency") as? PushRow<Frequency>?)??.value {
                        let tag = xrow == .never
                        self.formChanged()
                        if tag {
                            row.value = Date()
                        }
                        return tag
                    }
                    return false
                })
                }.onChange({ (row) in
                    try! rManager.realm.write {
                        self.event.repeatmodel?.end = (row.value?.toMillis())!
                    }
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
                        self.formChanged()
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
                $0.tag = "UsersRow"
                $0.value = UserListSelected(list: self.event.members.map({$0.id}))
                }.onChange({ (row) in
                    self.formChanged()
                    row.updateCell()
                })
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        animateScroll = true
        rowKeyboardSpacing = 20
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if event.id.isEmpty {
            self.tabBarController?.tabBar.isHidden = false
            event.repeatmodel = repeatEntity()
            let addBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
            self.tabBarController?.navigationItem.rightBarButtonItem = addBtn
            self.tabBarController?.navigationItem.title = "Nuevo Evento"
        }else{
            //            self.navigationController?.setNavigationBarHidden(false, animated: true)
            //            self.navigationController?.setToolbarHidden(false, animated: true)
            self.setStyle(.calendar)
            self.setupBack()
            let addBtn = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.save))
            self.navigationItem.title = "Editar Evento"
            self.navigationItem.rightBarButtonItem = addBtn
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !event.id.isEmpty {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    @objc func save() -> Void {
        let errors = form.validate()
        
        if errors.count == 0  {
            if event.id.isEmpty {
                store.dispatch(EventSvc(.save(event: self.event)))
                event = EventEntity()
            }else{
                let father = self.event.father != nil ? self.event.father  : self.event
                store.dispatch(EventSvc(.update(event: father!)))
                self.back3()
            }
            
            tableView.reloadData()
        } else {
            let t = ToastStyle()
            self.view.makeToast("\(errors.description)", duration: 5.0, point: self.view.center, title: "Errores", image: nil, style: t, completion: nil)
        }
        
    }
    
    
}
