//
//  GoalActions.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder

let goalActionTypeMap: TypeMap = [InsertGoalAction.type: InsertGoalAction.self,
                                  UpdateGoalAction.type: UpdateGoalAction.self,
                                  UpdateFollowAction.type: UpdateFollowAction.self]

struct InsertGoalAction: StandardActionConvertible {
    static let type = "GOAL_ACTION_INSERT"
    var goal: Goal!
    init(goal: Goal) {
        self.goal = goal
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertGoalAction.type, payload: [:], isTypedAction: true)
    }
}

struct UpdateGoalAction: StandardActionConvertible {
    static let type = "GOAL_ACTION_UPDATE"
    var goal: Goal!
    init(goal: Goal) {
        self.goal = goal
    }
    init(_ standardAction: StandardAction) {}
    func toStandardAction() -> StandardAction {
        return StandardAction(type: UpdateGoalAction.type, payload: [:], isTypedAction: true)
    }
}
struct UpdateFollowAction: StandardActionConvertible {
    static let type = "FOLLOWGOAL_ACTION_UPDATE"
    var follow: FollowGoal!
    var path: String!
    init(follow: FollowGoal, path: String) {
        self.follow = follow
        self.path = path
    }
    init(_ standardAction: StandardAction) {}
    func toStandardAction() -> StandardAction {
        return StandardAction(type: UpdateFollowAction.type, payload: [:], isTypedAction: true)
    }
}

struct GetGoalsAction: Action {
}

