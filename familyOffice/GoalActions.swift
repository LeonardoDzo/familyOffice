//
//  GoalActions.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Firebase
struct GoalActions {
    struct Insert: Action {
        var goal: Goal!
        init(goal: Goal) {
            self.goal = goal
        }
    }
    
    struct Update: Action {
        var goal: Goal!
        init(goal: Goal) {
            self.goal = goal
        }
        
    }
    struct UpdateFollow: Action {
        let goal: Goal!
        let path: String!
        init(_ path: String!, goal: Goal) {
            self.path = path
            self.goal = goal
        }
    }
    
    struct Get: Action {
    }
    
    struct routing: Action {
        var snapshot: DataSnapshot
        var event: DataEventType
        var ref: String
        init(_ snapshot: DataSnapshot,_ action: DataEventType,_ ref: String) {
            self.snapshot = snapshot
            self.event = action
            self.ref = ref
        }
    }
}



