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

    override func viewDidLoad() {
        super.viewDidLoad()
   
        form +++ Section("")
                <<< TextRow() { row in
                    row.title = "Titúlo"
                    row.placeholder = "Título"
                }
                <<< TextRow(){ row in
                    row.title = "Descripción"
                    row.placeholder = "Descripción"
                }
                <<< LocationRow(){
                    $0.title = "Ubicación"
                    }
            +++
                Section("")
                <<< SwitchRow() { row in
                    row.title = "Todo el día"
                    row.tag = "allDay"
                    }
                <<<  DateTimeRow() { row in
                    row.title = "Fecha de Inicio"
                    row.value = Date()
                    row.tag = "startDateTime"
                    row.hidden = Condition.function(["allDay"], { form in
                        return ((form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false)
                    })
                    }.onChange({ (row) in
                        if let eRow = self.form.rowBy(tag: "endDateTime") as? DateTimeRow {
                            eRow.updateCell()
                        }
                        
                    })
                <<<  DateTimeRow() { row in
                    row.hidden = Condition.function(["allDay"], { form in
                        return ((form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false)
                    })
                   
                    row.title = "Fecha de fin"
                    row.tag = "endDateTime"
                    }.cellUpdate { (cell, row) in
                        let value  = (self.form.rowBy(tag: "startDateTime") as! DateTimeRow).value ?? Date()
                        row.value = value
                        cell.datePicker.minimumDate = value
                }
                <<<  DateRow() { row in
                    row.hidden = Condition.function(["allDay"], { form in
                        return !((form.rowBy(tag: "allDay") as? SwitchRow)?.value ?? false)
                    })
                    row.value = Date()
                    row.title = "Fecha de Inicio"
                    row.tag = "startDate"
                    }.onChange({ (row) in
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
                    }.cellUpdate { (cell, row) in
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
                    
                })
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
   
    
    }
    

}
