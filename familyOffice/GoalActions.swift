//
//  GoalActions.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift


struct InsertGoalAction: Action {
    var goal: Goal!
    init(goal: Goal) {
        self.goal = goal
    }
}

struct UpdateGoalAction: Action {
    var goal: Goal!
    init(goal: Goal) {
        self.goal = goal
    }
    
}
struct UpdateFollowAction: Action {
    var follow: FollowGoal!
    var path: String!
    init(follow: FollowGoal, path: String) {
        self.follow = follow
        self.path = path
    }
   
}

struct GetGoalsAction: Action {
}

