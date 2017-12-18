//
//  InsuranceService.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazar on 12/18/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

class InsuranceService: RequestService{
    func notExistSnapshot() {
        
    }
    
    var insurances: [Insurance] = []
    var handles: [(String,UInt,DataEventType)] = []
    
    private init() {}
    
    static private let instance = InsuranceService()
    
    public static func Instance() -> InsuranceService { return instance}
    
    func routing(snapshot: DataSnapshot, action: DataEventType, ref: String) {
        switch action{
        case .childAdded:
            self.added(snapshot:snapshot)
            break
        case .childChanged:
            self.updated(snapshot:snapshot, id: snapshot.key)
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
    func initObservers(ref: String, actions: [DataEventType]) -> Void{
        for action in actions {
            if !handles.contains(where: {$0.0 == ref && $0.2 == action}){
                self.child_action(ref: ref, action: action)
            }
        }
    }
    
    func addHandle(_ handle: UInt, ref: String, action: DataEventType) {
        
        self.handles.append((ref, handle, action))
    }
    
    func removeHandles() {
        for handle in self.handles{
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    
    func inserted(ref: DatabaseReference) {
        store.state.insuranceState.status = .none
    }
}

extension InsuranceService: repository {
    func added(snapshot: DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let insurance = Insurance(snapshot: snapshot)
        
        if store.state.insuranceState.insurances[id] == nil {
            store.state.insuranceState.insurances[id] = []
        }
        
        if !(store.state.insuranceState.insurances[id]?.contains(where: {$0.id == insurance.id}))!{
            store.state.insuranceState.insurances[id]?.append(insurance)
        }
    }
    
    func updated(snapshot: DataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let insurance = Insurance(snapshot: snapshot)
        if let index = store.state.insuranceState.insurances[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.insuranceState.insurances[id]?[index] = insurance
        }
    }
    
    func removed(snapshot: DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        if let index = store.state.insuranceState.insurances[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.insuranceState.insurances[id]?.remove(at: index)
        }
    }
    
}

