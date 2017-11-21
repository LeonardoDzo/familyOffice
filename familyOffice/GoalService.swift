//
//  GoalService.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 23/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase
import ReSwift

enum typeGoal {
    case Individual,
         Familiar
}

let defaults = UserDefaults.standard
class GoalService: RequestService {
    func notExistSnapshot() {
        
    }
    var type: typeGoal! = .Individual
    var goals: [Goal] = []
    var handles: [(String,UInt,DataEventType)] = []
    private init() {}
    
    static private let instance = GoalService()
    
    public static func Instance() -> GoalService { return instance }
    
    func routing(snapshot: DataSnapshot, action: DataEventType, ref: String) {
         store.dispatch(gac.routing(snapshot, action, ref))
    }
    
    func initObserves(ref: String, actions: [DataEventType]) -> Void {
        for action in actions {
            if !handles.contains(where: { $0.0 == ref && $0.2 == action} ){
                self.child_action(ref: ref, action: action)
            }
        }
    }
    
    func addHandle(_ handle: UInt, ref: String, action: DataEventType) {
        self.handles.append((ref,handle, action))
    }
    
    func removeHandles() {
        for handle in self.handles {
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    
    func inserted(ref: DatabaseReference) {
        Constants.FirDatabase.REF_USERS.child((userStore?.id!)!).child("goals").updateChildValues([ref.key:true])
        
        store.state.GoalsState.status = .finished
        
    }
    
    func create(_ xgoal: Goal) -> Void {
        var goal = xgoal
        let id = getPath(type: goal.type!)
        let path = "goals/\(id)/\(goal.id!)"
        if goal.type == 1 {
            goal.members = {
                let fid = userStore?.familyActive
                var members = [String:Int]()
                store.state.FamilyState.families.family(fid: fid!)?.members.forEach({s in
                    members[s] = -1
                })
                return members
            }()
        }else{
            goal.members[(userStore?.id)!] = -1
        }
       
        if var json = goal.toJSON()  {
            json["repeat"] = goal.repeatGoalModel?.toDictionary()
            self.insert(path, value: json, callback: {ref in
                if ref is DatabaseReference {
                    //store.state.GoalsState.goals[id]?.append(goal)
                }
            })
        }
    }
    
    func updateGoal(_ goal: Goal) -> Void {
        let id = getPath(type: goal.type!)
        let path = "goals/\(id)/\(goal.id!)"
        if var json = goal.toJSON() {
            json["repeat"] = goal.repeatGoalModel?.toDictionary()
            service.GOAL_SERVICE.update(path, value: json, callback: { ref in
                if ref is DatabaseReference {
                    if let index = store.state.GoalsState.goals[id]?.index(where: {$0.id == goal.id }){
                        store.state.GoalsState.goals[id]?[index] = goal
                        store.state.GoalsState.status = .Finished(goal)
                    }
                    
                }
                
            })
        }
    }

    func updateFollow(_ follow: Goal, path: String) -> Void {

        if let json = follow.toJSON() {
            self.update(path, value: json, callback: {
                ref in
                if ref is DatabaseReference {
                    let array = path.components(separatedBy: "/")
                    let fid = array[1]
                    let gid = array[2]
                    if let index = store.state.GoalsState.goals[fid]?.index(where: {$0.id == gid}) {
                        if let indexF = store.state.GoalsState.goals[fid]?[index].list.index(where: {$0.startDate == follow.startDate})  {
                            store.state.GoalsState.goals[fid]?[index].list[indexF] = follow
                            let goal = store.state.GoalsState.goals[fid]?[index]
                            store.state.GoalsState.status = .Finished(goal!)
                        }
                    }
                }
            })
        }
        
    }
    
    func delete(_ ref: String, callback: @escaping ((Any) -> Void)) {
    }
    
    func getPath(type: Int) -> String {
        if type == 0 {
            return store.state.UserState.getUser()!.id!
        }else{
            return store.state.UserState.getUser()!.familyActive!
        }
    }
    
    
}
