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

class EventViewController: FormViewController {
    var event = EventEntity()
    override func viewDidLoad() {
        super.viewDidLoad()
        let addBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        self.tabBarController?.navigationItem.rightBarButtonItem = addBtn
        form +++ Section("")
                <<< TextRow() { row in
                    row.title = "Titúlo"
                    row.placeholder = "Título"
                    }.onChange({ (row) in
                        self.event.title = row.value
                        })
            
                <<< TextRow(){ row in
                    row.title = "Descripción"
                    row.placeholder = "Descripción"
                    }.onChange({ (row) in
                        self.event.details = row.value
                    })
                <<< LocationRow(){
                    $0.title = "Ubicación"
                    }.onChange({ (row) in
                        self.event.location = row.value
                    })
            +++
                Section("")
                <<< SwitchRow() { row in
                    row.title = "Todo el día"
                    row.tag = "allDay"
                    }.onChange({ (row) in
                        self.event.isAllDay = row.value
                    })
                <<<  DateTimeRow() { row in
                    row.title = "Fecha de Inicio"
                    row.value = Date()
                    row.tag = "startDateTime"
                    row.add(rule: RuleRequired())
                    row.hidden = Condition.function(["allDay"], { form in
                        return ((form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false)
                    })
                    }.onChange({ (row) in
                        self.event.startdate = (row.value?.toMillis())!
                        if let eRow = self.form.rowBy(tag: "endDateTime") as? DateTimeRow {
                            eRow.updateCell()
                        }
                        
                    })
                <<<  DateTimeRow() { row in
                    row.hidden = Condition.function(["allDay"], { form in
                        return ((form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false)
                    })
                    row.add(rule: RuleRequired())
                    row.title = "Fecha de fin"
                    row.tag = "endDateTime"
                    }.onChange({ (row) in
                        self.event.enddate = (row.value?.toMillis())!
                    }).cellUpdate { (cell, row) in
                        let value  = (self.form.rowBy(tag: "startDateTime") as! DateTimeRow).value ?? Date()
                        cell.datePicker.minimumDate = value
                }
                <<<  DateRow() { row in
                    row.hidden = Condition.function(["allDay"], { form in
                        return !((form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false)
                    })
                    row.value = Date()
                    row.title = "Fecha de Inicio"
                    row.tag = "startDate"
                    row.add(rule: RuleRequired())
                    }.onChange({ (row) in
                        self.event.startdate = (row.value?.toMillis())!
                        if let eRow = self.form.rowBy(tag: "endDate") as? DateRow {
                            eRow.updateCell()
                        }
                        
                    })
                <<<  DateRow() { row in
                    row.hidden = Condition.function(["allDay"], { form in
                        return !((form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false)
                    })
                    row.value = Date()
                    row.title = "Fecha de fin"
                    row.tag = "endDate"
                    }.onChange({ (row) in
                        self.event.enddate = (row.value?.toMillis())!
                    }).cellUpdate { (cell, row) in
                        let value  = (self.form.rowBy(tag: "startDate") as! DateRow).value ?? Date()
                        row.value = value
                        cell.datePicker.minimumDate = value
                    }
                <<< PushRow<Frequency>() { row in
                    row.title = "Repetir"
                    row.options = [.never,.daily,.weekly, .monthly, .year]
                    row.value = .never
                    row.tag = "frequency"
                    row.selectorTitle = "Escogé un tipo de sangre"
                    }.onChange({ (row) in
                        if row.isValid {
                            self.event.repeatmodel = repeatEntity()
                            self.event.repeatmodel?.frequency = row.value
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
                    
                    row.hidden = Condition.function(["frequency"], { form in
                       
                        if let xrow = (form.rowBy(tag: "frequency") as? PushRow<Frequency>?)??.value {
                            let tag = xrow == .never
                            self.event.repeatmodel?.end = row.value?.toMillis()
                            if tag {
                                row.value = Date()
                            }
                            return tag
                        }
                        return false
                    })
                }
            +++ Section()
            <<< PushRow<eventType>() { row in
                row.title = "Tipo"
                row.options = [.Default,.BirthDay,.Meet]
                row.value = .Default
                row.tag = "type"
                row.selectorTitle = "Escogé un tipo de evento"
                }.onChange({ (row) in
                    if row.isValid {
                        self.event.eventtype = row.value!
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
                })
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
   
    
    }
    
    @objc func save() -> Void {
        store.dispatch(EventSvc(.save(event: self.event)))
    }
    

}
