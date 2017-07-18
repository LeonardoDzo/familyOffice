//
//  ContactActions.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 11/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder
let contactActionTypeMap: TypeMap = [InsertContactAction.type: InsertContactAction.self,
                                  UpdateContactAction.type: UpdateContactAction.self]

struct InsertContactAction: StandardActionConvertible {
    static let type = "CONTACT_ACTION_INSERT"
    var contact: Contact!
    init(contact: Contact) {
        self.contact = contact
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertContactAction.type, payload: [:], isTypedAction: true)
    }
}

struct UpdateContactAction: StandardActionConvertible {
    static let type = "CONTACT_ACTION_UPDATE"
    var contact: Contact!
    init(contact: Contact) {
        self.contact = contact
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: UpdateContactAction.type, payload: [:], isTypedAction: true)
    }
}
