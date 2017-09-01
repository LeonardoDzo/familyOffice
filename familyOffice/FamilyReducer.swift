//
//  FamilyReducer.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 04/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct FamilyReducer{
    func handleAction(action: Action, state: FamilyState?) -> FamilyState {
        var state = state ?? FamilyState(families: FamilyList(), status: .none)
        switch action {
        case let action as InsertFamilyAction:
            if action.family != nil {
                state.status = .loading
                if action.family.id.isEmpty {
                   service.FAMILY_SVC.create(family: action.family, with: action.famImage)
                }
            }
            break
        case let action as UpdateFamilyAction:
            if action.family != nil {
                state.status = .loading
                service.FAMILY_SVC.update(family: action.family, with: action.famImage)
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
