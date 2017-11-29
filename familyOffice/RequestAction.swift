//
//  RequestAction.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Firebase


struct RequestAction: Action {
    var service: Any!
    var snapshot: DataSnapshot!
    init(service: RequestService, snapshot: DataSnapshot) {
        self.service = service
        self.snapshot = snapshot
    }

}
