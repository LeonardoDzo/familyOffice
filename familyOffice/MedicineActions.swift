//
//  MedicineActions.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/19/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder

let medicineActionTypeMap: TypeMap = [
    InsertMedicineAction.type: InsertMedicineAction.self,
    UpdateMedicineAction.type: UpdateMedicineAction.self,
    DeleteMedicineAction.type: DeleteMedicineAction.self]

struct InsertMedicineAction: StandardActionConvertible {
    static let type = "MEDICINE_ACTION_INSERT"
    var medicine: Medicine!
    init(medicine: Medicine){
        self.medicine = medicine
    }
    init(_ standardAction: StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertMedicineAction.type, payload: [:], isTypedAction: true)
    }
}

struct UpdateMedicineAction: StandardActionConvertible {
    static let type = "MEDICINE_ACTION_UPDATE"
    var medicine: Medicine!
    init(medicine: Medicine){
        self.medicine = medicine
    }
    init(_ standardAction: StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: UpdateMedicineAction.type, payload: [:], isTypedAction: true)
    }
}

struct DeleteMedicineAction: StandardActionConvertible {
    static let type = "MEDICINE_ACTION_DELETE"
    var medicine: Medicine!
    init(medicine: Medicine){
        self.medicine = medicine
    }
    init(_ standardAction: StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: DeleteMedicineAction.type, payload: [:], isTypedAction: true)
    }
}
