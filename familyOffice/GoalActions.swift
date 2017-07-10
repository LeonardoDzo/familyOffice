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
    let goal: Goal
}
struct UpdateGoalAction: Action {
    let goal: Goal
}

struct GetGoalsAction: Action {
}

