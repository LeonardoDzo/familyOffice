//
//  FamilyReducer.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 04/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct FamilyReducer: Reducer {
    func handleAction(action: Action, state: FamilyState?) -> FamilyState {
        var state = state ?? FamilyState(families: FamilyList(), status: .none)
        switch action {
        case let action as InsertFamilyAction:
            if action.family != nil {
                service.FAMILY_SVC.create(family: action.family, with: action.famImage)
                state.status = .loading
            }
            break
        case let action as DeleteFamilyAction:
            if action.fid != nil {
                service.FAMILY_SVC.delete(family: action.fid)
                state.status = .loading
            }
            break
        default:
            break
        }
        
        return state
    }
}
