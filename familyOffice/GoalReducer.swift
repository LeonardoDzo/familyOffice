//
//  GoalReducer.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
import Firebase

struct GoalReducer: Reducer {
    
    func handleAction(action: Action, state: GoalState?) -> GoalState {
        var state = state ?? GoalState(goals: [:], status: .none)
        switch action {
        case let action as InsertGoalAction:
            if action.goal == nil {
               return state
            }
            service.GOAL_SERVICE.create(action.goal)
            state.status = .loading
        case let action as UpdateGoalAction:
            if action.goal == nil {
                return state
            }
            service.GOAL_SERVICE.updateGoal(action.goal)
            state.status = .loading
            return state
        case let action as UpdateFollowAction:
            if action.follow != nil {
                service.GOAL_SERVICE.updateFollow(action.follow, path: action.path)
            }
            break
        default: break
        }
        return state
    }

}


