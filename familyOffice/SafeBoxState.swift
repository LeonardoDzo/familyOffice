//
//  SafeBoxState.swift
//  familyOffice
//
//  Created by Developer on 8/16/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct SafeBoxState: StateType{
    var safeBoxFiles: [String:[SafeBoxFile]] = [:]
    var status: Result<Any> = .none
}
