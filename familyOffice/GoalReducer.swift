//
//  GoalReducer.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Firebase
/// Reference to GoalActions
typealias gac = GoalActions

struct GoalReducer  {
    var state: GoalState! = nil
    init(_ state: GoalState?) {
        self.state = state ?? GoalState(goals: [:], status: .none)
    }
    mutating func handleAction(action: Action) -> GoalState {
        switch action {
        case let action as gac.Insert:
            if action.goal == nil {
               return self.state
            }
            self.state?.status = .loading
            service.GOAL_SERVICE.create(action.goal)
        case let action as gac.Update:
            if action.goal == nil {
                return state!
            }
             self.state.status = .loading
            service.GOAL_SERVICE.updateGoal(action.goal)
        case let action as gac.UpdateFollow:
            if action.goal != nil {
                service.GOAL_SERVICE.updateFollow(action.goal, path: action.path)
            }
            break
        case let action as gac.Update:
            if action.goal != nil {
                service.GOAL_SERVICE.updateGoal(action.goal)
            }
            break
        case let action as gac.routing:
                    switch action.event {
                    case .childAdded:
                       self.added(snapshot: action.snapshot)
                        break
                    case .childRemoved:
                        self.removed(snapshot:  action.snapshot)
                        break
                    case .childChanged:
                        self.updated(snapshot:  action.snapshot, id:  action.snapshot.key)
                        break
                    case .value:
                        //self.add(value: snapshot)
                        break
                    default:
                        break
                    }
            break
        default: break
        }
        return  self.state
    }
    mutating func added(snapshot: DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let goal = Goal(snapshot: snapshot)
        
        if (self.state.goals[id] == nil) {
            self.state.goals[id] = []
        }
        
        if !(self.state.goals[id]?.contains(where: {$0.id == goal.id}))!{
            self.state.goals[id]?.append(goal)
        }else if let index = self.state.goals[id]?.index(where: {$0.id == goal.id}){
            self.state.goals[id]?[index] = goal
        }
    }
    
    mutating func updated(snapshot: DataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let goal = Goal(snapshot: snapshot)
        if let index = self.state.goals[id]?.index(where: {$0.id == snapshot.key})  {
            self.state.goals[id]?[index] = goal
        }
    }
    
    mutating func removed(snapshot: DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        if let index = self.state.goals[id]?.index(where: {$0.id == snapshot.key})  {
            self.state.goals[id]?.remove(at: index)
        }
    }


}
