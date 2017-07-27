//
//  IllnessService.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/20/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

class IllnessService: RequestService {
    
    func notExistSnapshot() {
        
    }
    
    var illnesses: [Illness] = []
    var handles: [(String, UInt, FIRDataEventType)] = []
    private init() {}
    
    static private let instance = IllnessService()
    
    public static func Instance() -> IllnessService { return instance }
    
    func routing(snapshot: FIRDataSnapshot, action: FIRDataEventType, ref: String) {
        switch action {
        case .childAdded:
            self.added(snapshot:snapshot)
            break
        case .childChanged:
            self.updated(snapshot: snapshot, id: snapshot.key)
            break
        case .childRemoved:
            self.removed(snapshot:snapshot)
            break
        case .value:
            break
        default:
            break
        }
    }
    
    func initObservers(ref: String, actions: [FIRDataEventType]) -> Void {
        for action in actions {
            if !handles.contains(where: {$0.0 == ref && $0.2 == action}){
                self.child_action(ref: ref, action: action)
            }
        }
    }
    
    func addHandle(_ handle: UInt, ref: String, action: FIRDataEventType) {
        self.handles.append(ref, handle, action)
    }
    
    func removeHandles() {
        for handle in self.handles {
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    
    func inserted(ref: FIRDatabaseReference) {
    Constants.FirDatabase.REF_FAMILIES.child((store.state.UserState.user?.familyActive)!).child("illnesses").updateChildValues([ref.key:true])
        
        store.state.IllnessState.status = .none
    }
    
    func create(_ nIllness: Illness) -> Void{
        let illness = nIllness
        let id = store.state.UserState.user!.familyActive!
        let path = "illnesses/\(id)/\(illness.id!)"
        
        service.ILLNESS_SERVICE.insert(path, value: illness.toDictionary(), callback: {ref in
            if ref is FIRDatabaseReference {
                store.state.IllnessState.illnesses[id]?.append(illness)
            }
        })
    }
}

extension IllnessService: repository {
    func added(snapshot: FIRDataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let illness = Illness(snapshot: snapshot)
        
        if store.state.IllnessState.illnesses[id] == nil {
            store.state.IllnessState.illnesses[id] = []
        }
        
        if !(store.state.IllnessState.illnesses[id]?.contains(where: {$0.id == illness.id}))!{
            store.state.IllnessState.illnesses[id]?.append(illness)
        }
    }
    
    func updated(snapshot: FIRDataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let illness = Illness(snapshot: snapshot)
        if let index = store.state.IllnessState.illnesses[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.IllnessState.illnesses[id]?[index] = illness
        }
    }
    
    func removed(snapshot: FIRDataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        if let index = store.state.IllnessState.illnesses[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.IllnessState.illnesses[id]?.remove(at: index)
        }
    }
}
