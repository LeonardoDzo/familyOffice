//
//  EventProtocol.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import RealmSwift

protocol EventProtocol {
    associatedtype EnumType
    var action: EnumType {get set}
    var status: Result<Any>! {get set}
    var fromView: RoutingDestination! {get set}
}

@objcMembers
class EventProccess: Object, EventProtocol {

    
    convenience required init(builder: Object) {
        self.init()
        
    }
}
