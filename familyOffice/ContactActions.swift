//
//  ContactActions.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 11/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct InsertContactAction: Action {
    var contact: Contact!
    init(contact: Contact) {
        self.contact = contact
    }
}

struct UpdateContactAction: Action {
    var contact: Contact!
    init(contact: Contact) {
        self.contact = contact
    }
}
