//
//  InsuranteState.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazar on 12/16/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct InsuranceState: StateType{
    var insurances: [String:[Insurance]] = [:]
    var status: Result<Any> = .none
}
