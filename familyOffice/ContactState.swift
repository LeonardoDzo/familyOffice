//
//  ContactState.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 11/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct ContactState : StateType {
    var contacts = [String:[Contact]]()
    var status : Result<Any> = .loading
}
