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

protocol EventConfig : AnyObject {
    associatedtype EnumType
    var action: EnumType {get set}
}


protocol EventProtocol : EventConfig, EventDescription {
}

protocol EventDescription  {
    var status: Result<Any> {get set}
    var fromView: RoutingDestination! {get set}
    var id: String! {get set}
    
}
extension EventDescription {
    func getDescription() -> String {
        return self.status.description
    }
}

@objcMembers
class EventProccess: Object {
    dynamic var id = ""
    dynamic var action: String = ""
    dynamic var status: Result<Any>! = .none
    dynamic var fromView: String! = ""
    
    convenience required init(builder: EventDescription) {
        self.init()
        self.action = builder.getDescription()
        self.fromView = builder.fromView == nil ? "none" : builder.fromView.rawValue
        self.id = builder.id
        self.status = builder.status
        
    }
    override static func primaryKey() -> String? {
        return "id"
    }
}

