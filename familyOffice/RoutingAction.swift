//
//  RoutingAction.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import FirebaseAuth

struct RoutingAction: Action {
    var destination: RoutingDestination!
    init(d: RoutingDestination) {
        self.destination = d
    }
}
