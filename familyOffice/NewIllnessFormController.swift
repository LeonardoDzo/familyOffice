//
//  NewIllnessFormController.swift
//  familyOffice
//
//  Created by Nan Montaño on 05/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Eureka
import ReSwift

class NewIllnessFormController: FormViewController {
    
    var illness = IllnessEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // done button
        let doneButton = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.save))
        self.navigationItem.rightBarButtonItem = doneButton
        // family
        getUser(closure: {user in
            self.illness.family = user!.familyActive
        })
        // form
        form +++ Section()
            <<< createTextRow(title: "Nombre", tag: "name")
            <<< createTextRow(title: "Dosis", tag: "dosage")
            <<< createTextRow(title: "Medicina", tag: "medicine")
            <<< createTextRow(title: "Mas información", tag: "moreInfo")
    }
    
    func createTextRow(title: String, tag: String) -> TextRow {
        return TextRow() {
            $0.title = title
            $0.add(rule: RuleRequired())
            $0.validationOptions = .validatesOnChange
            $0.tag = tag
        }.cellUpdate {cell, row in
                if !row.isValid { cell.titleLabel?.textColor = .red }
        }
    }
    
    @objc func save(_ sender: Any) {
        let values = form.values()
        illness.name = values["name"] as! String
        illness.dosage = values["dosage"] as! String
        illness.medicine = values["medicine"] as! String
        illness.moreInfo = values["moreInfo"] as! String
        store.dispatch(newIllnessAction(illness: illness))
    }
}

extension NewIllnessFormController: StoreSubscriber {
    typealias StoreSubscriberStateType = IllnessState
    
    func newState(state: IllnessState) {
        // todo
    }
}
