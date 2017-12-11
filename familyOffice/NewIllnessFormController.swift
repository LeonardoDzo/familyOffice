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
    
    var action: FormAction = .Create
    var newIllnessUuid: String?
    var entity: Any = IllnessEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // done button
        if let illness = entity as? IllnessEntity {
            let doneButton = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.saveIllness))
            self.navigationItem.rightBarButtonItem = doneButton
            form +++ Section()
                <<< createTextRow(title: "Nombre", tag: "name", value: illness.name)
                <<< createTextRow(title: "Dosis", tag: "dosage", value: illness.dosage)
                <<< createTextRow(title: "Medicina", tag: "medicine", value: illness.medicine)
                <<< createTextRow(title: "Mas información", tag: "moreInfo", value: illness.moreInfo)
        } else if let medicine = entity as? MedicineEntity {
            let doneButton = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.saveMedicine))
            self.navigationItem.rightBarButtonItem = doneButton
            form +++ Section()
                <<< createTextRow(title: "Nombre", tag: "name", value: medicine.name)
                <<< createTextRow(title: "Dosis", tag: "dosage", value: medicine.dosage)
                <<< createTextRow(title: "Indicaciones", tag: "indications", value: medicine.indications)
                <<< createTextRow(title: "Restricciones", tag: "restrictions", value: medicine.restrictions)
                <<< createTextRow(title: "Mas información", tag: "moreInfo", value: medicine.moreInfo)
        }
        // form
    }
    
    func createTextRow(title: String, tag: String, value: String = "") -> TextRow {
        return TextRow() {
            $0.title = title
            $0.value = value
            $0.add(rule: RuleRequired())
            $0.validationOptions = .validatesOnChange
            $0.tag = tag
        }.cellUpdate {cell, row in
                if !row.isValid { cell.titleLabel?.textColor = .red }
        }
    }
    
    @objc func saveIllness(_ sender: Any) {
        let values = form.values()
        let illness = entity as! IllnessEntity
        let _illness = IllnessEntity()
        _illness.family = getUser()!.familyActive
        _illness.name = values["name"] as! String
        _illness.dosage = values["dosage"] as! String
        _illness.medicine = values["medicine"] as! String
        _illness.moreInfo = values["moreInfo"] as! String
        newIllnessUuid = UUID().uuidString
        if action == .Create {
            store.dispatch(newIllnessAction(illness: _illness, uuid: newIllnessUuid!))
        } else {
            store.dispatch(editIllnessAction(illness: illness, fields: _illness, uuid: newIllnessUuid!))
        }
    }
    
    @objc func saveMedicine(_ sender: Any) {
        let values = form.values()
        let medicine = entity as! MedicineEntity
        let _medicine = MedicineEntity()
        _medicine.family = getUser()!.familyActive
        _medicine.name = values["name"] as! String
        _medicine.dosage = values["dosage"] as! String
        _medicine.indications = values["indications"] as! String
        _medicine.restrictions = values["restrictions"] as! String
        _medicine.moreInfo = values["moreInfo"] as! String
        newIllnessUuid = UUID().uuidString
        if action == .Create {
            store.dispatch(newMedicineAction(medicine: _medicine, uuid: newIllnessUuid!))
        } else {
            store.dispatch(editMedicineAction(medicine: medicine, fields: _medicine, uuid: newIllnessUuid!))
        }
    }
}

extension NewIllnessFormController: StoreSubscriber {
    typealias StoreSubscriberStateType = RequestState
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { state in
            state.select { $0.requestState }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    func newState(state: RequestState) {
        guard let reqId = newIllnessUuid else { return }
        switch state.requests[reqId] {
        case .finished?:
            navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
    }
}

enum FormAction {
    case Create, Update
}
