//
//  GoalService.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 23/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import FirebaseDatabase
let defaults = UserDefaults.standard
class GoalService: RequestService {
    func notExistSnapshot() {
        
    }

    var goals: [Goal] = []
    var handles: [(String,UInt,FIRDataEventType)] = []
    let basePath = "goals/\(service.USER_SERVICE.users[0].id!)"
    private init() {}
    
    static private let instance = GoalService()
    
    public static func Instance() -> GoalService { return instance }
    
    func routing(snapshot: FIRDataSnapshot, action: FIRDataEventType, ref: String) {
        switch action {
        case .childAdded:
            self.added(snapshot: snapshot)
            break
        case .childRemoved:
            self.removed(snapshot: snapshot)
            break
        case .childChanged:
            self.updated(snapshot: snapshot, id: snapshot.key)
            break
        case .value:
            //self.add(value: snapshot)
            break
        default:
            break
        }
    }
    
    func initObserves(ref: String, actions: [FIRDataEventType]) -> Void {
        for action in actions {
            if !handles.contains(where: { $0.0 == ref && $0.2 == action} ){
                self.child_action(ref: ref, action: action)
            }
        }
    }
    
    func addHandle(_ handle: UInt, ref: String, action: FIRDataEventType) {
        self.handles.append(ref,handle, action)
    }
    
    func removeHandles() {
        for handle in self.handles {
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    
    func inserted(ref: FIRDatabaseReference) {
        Constants.FirDatabase.REF_USERS.child(service.USER_SERVICE.users[0].id!).child("goals").updateChildValues([ref.key:true])
        
        store.state.GoalsState.status = .finished
        
    }
    
    func create(_ xgoal: Goal) -> Void {
        var goal = xgoal
        let id = getPath(type: goal.type)
        let path = "goals/\(id)/\(goal.id!)"
        if goal.type == 1 {
            goal.members = {
                let fid = store.state.UserState.user?.familyActive
                var members = [String:Int]()
                store.state.FamilyState.families.first(where: {$0.id == fid})?.members.forEach({s in
                    members[s] = -1
                })
                return members
            }()
        }
        service.GOAL_SERVICE.insert(path, value: goal.toDictionary(), callback: {ref in
            if ref is FIRDatabaseReference {
                store.state.GoalsState.goals[id]?.append(goal)
            }
        })
    }
    
    func updateGoal(_ goal: Goal) -> Void {
        let id = getPath(type: goal.type)
        let path = "goals/\(id)/\(goal.id!)"
        service.GOAL_SERVICE.update(path, value: goal.toDictionary() as! [AnyHashable : Any], callback: { ref in
            if ref is FIRDatabaseReference {
                if let index = store.state.GoalsState.goals[id]?.index(where: {$0.id == goal.id }){
                    store.state.GoalsState.goals[id]?[index] = goal
                    store.state.GoalsState.status = .Finished(goal)
                }
                
            }
            
        })
    }

    func updateFollow(_ follow: FollowGoal, path: String) -> Void {
        self.update(path, value: follow.members , callback: {
            ref in
            if ref is FIRDatabaseReference {
                let array = path.components(separatedBy: "/")
                let fid = array[1]
                let gid = array[2]
                if let index = store.state.GoalsState.goals[fid]?.index(where: {$0.id == gid}) {
                    if let indexF = store.state.GoalsState.goals[fid]?[index].follow.index(where: {$0.date == follow.date})  {
                        store.state.GoalsState.goals[fid]?[index].follow[indexF].members = follow.members
                        let goal = store.state.GoalsState.goals[fid]?[index]
                        store.state.GoalsState.status = .Finished(goal!)
                    }
                }
                
                
            }
        })
        
    }
    
    func delete(_ ref: String, callback: @escaping ((Any) -> Void)) {
    }
    
    func getPath(type: Int) -> String {
        if type == 0 {
            return store.state.UserState.user!.id!
        }else{
            return store.state.UserState.user!.familyActive!
        }
    }
    
}

extension GoalService: repository {
    
    func added(snapshot: FirebaseDatabase.FIRDataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4]
        let goal = Goal(snapshot: snapshot)
        
        if (store.state.GoalsState.goals[id] == nil) {
            store.state.GoalsState.goals[id] = []
        }
        
        if !(store.state.GoalsState.goals[id]?.contains(where: {$0.id == goal.id}))!{
            store.state.GoalsState.goals[id]?.append(goal)
        }
    }
    
    func updated(snapshot: FirebaseDatabase.FIRDataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4]
        let goal = Goal(snapshot: snapshot)
        if let index = store.state.GoalsState.goals[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.GoalsState.goals[id]?[index] = goal
        }
    }
    
    func removed(snapshot: FirebaseDatabase.FIRDataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4]
        if let index = store.state.GoalsState.goals[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.GoalsState.goals[id]?.remove(at: index)
        }
    }
}
