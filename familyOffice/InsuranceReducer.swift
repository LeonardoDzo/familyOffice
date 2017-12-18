//
//  InsuranceReducer.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazat on 12/18/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct InsuranceReducer {
    func handleAction(action: Action, state: InsuranceState?) -> InsuranceState {
        var state = state ?? InsuranceState(insurances: [:], status: .none)
        return state
    }
}
