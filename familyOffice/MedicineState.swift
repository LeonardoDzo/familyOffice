//
//  MedicineState.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/19/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct MedicineState: StateType{
    var medicines: [String:[Medicine]] = [:]
    var status : Result<Any> = .none
}
