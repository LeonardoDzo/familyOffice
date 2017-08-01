//
//  ContactReducer.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 11/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct ContactReducer: Reducer {
    func handleAction(action: Action, state: ContactState?) -> ContactState {
        var state = state ?? ContactState(contacts: [:], status: .none)
        
        switch action {
        case let action as InsertContactAction:
            if action.contact != nil {
                state.status = .loading
                service.CONTACT_SVC.create(action.contact)
            }
            break
        case let action as UpdateContactAction:
            if action.contact != nil {
                state.status = .loading
                service.CONTACT_SVC.update(action.contact)
            }
            break
        default:
            break
        }
        return state
    }
}
