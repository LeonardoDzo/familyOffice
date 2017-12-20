//
//  RequestAction.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

// Esto ya estaba aqui pero creo que no se usa
//struct RequestAction: Action {
//    var service: Any!
//    var snapshot: DataSnapshot!
//    init(service: RequestService, snapshot: DataSnapshot) {
//        self.service = service
//        self.snapshot = snapshot
//    }
//
//}

enum RequestError : Error {
    case NotFound, NotJson, NotData, CouldNotWrite
}

enum RequestAction: Action {
    case Loading(uuid: String)
    case Done(uuid: String)
    case Error(err: RequestError, uuid: String)
    case Processed(uuid: String)
}
