//
//  IllnessState.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/19/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct IllnessState: StateType {
    var illnesses: [String:[Illness]] = [:]
    var status : Result<Any> = .none
    var requests: [String : Result<Any>] = [:]
}
