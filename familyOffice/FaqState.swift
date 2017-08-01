//
//  FaqState.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/25/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct FaqState: StateType{
    var questions: [String:[Question]] = [:]
    var status: Result<Any> = .none
}
