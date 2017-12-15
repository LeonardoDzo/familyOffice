//
//  MedicineActions.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/19/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct InsertMedicineAction: Action {
    var medicine: Medicine!
    init(medicine: Medicine){
        self.medicine = medicine
    }
}

struct UpdateMedicineAction: Action {
    var medicine: Medicine!
    init(medicine: Medicine){
        self.medicine = medicine
    }
}

struct DeleteMedicineAction: Action {
    var medicine: Medicine!
    init(medicine: Medicine){
        self.medicine = medicine
    }
}
