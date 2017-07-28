//
//  FamilyState.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 18/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct FamilyState: StateType {
    var families : FamilyList
    var status: Result<Any> = .none
}
