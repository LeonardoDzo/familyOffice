//
//  FamilySvc.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

class FamilySvc {
    var handles: [(String, UInt, FIRDataEventType)] = []
    private static let instance : FamilySvc = FamilySvc()
    
    
    private init() {
    }
    
    public static func Instance() -> FamilySvc {
        return instance
    }
    
    func initObserves(ref: String, actions: [FIRDataEventType]) -> Void {
        for action in actions {
            if !handles.contains(where: { $0.0 == ref && $0.2 == action} ){
                self.child_action(ref: ref, action: action)
            }
        }
    }
    
    
}

extension FamilySvc: RequestService {
    func notExistSnapshot() {
        
    }

    func addHandle(_ handle: UInt, ref: String, action: FIRDataEventType) {
        self.handles.append((ref,handle,action))
    }
    func inserted(ref: FIRDatabaseReference) {
        store.state.FamilyState.status = .finished
    }
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
            self.added(snapshot: snapshot)
            break
        default:
            break
        }
    }
    
    func removeHandles() {
        for handle in self.handles {
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    
    func delete(_ ref: String, callback: @escaping ((Any) -> Void)) {
    }
    
}

extension FamilySvc: repository {
    func added(snapshot: FIRDataSnapshot) {
        let family : Family = Family(snapshot: snapshot)
        if !store.state.FamilyState.families.contains(where: {$0.id == family.id}) {
            store.state.FamilyState.families.append(family)
            self.initObserves(ref: ref_family(family.id!), actions: [.childChanged])
        }
    }
    func removed(snapshot: FIRDataSnapshot) {
        let key : String = snapshot.key
        if let index = store.state.FamilyState.families.index(where: {$0.id == key}) {
            let family = store.state.FamilyState.families[index]
            store.state.FamilyState.families.remove(at: index)
            ToastService.getTopViewControllerAndShowToast(text: "Familia eliminada: \(family.name!)")
        }
        
    }
    
    func updated(snapshot: FIRDataSnapshot, id: Any) {
        let family : Family = Family(snapshot: snapshot)
        if let index = store.state.FamilyState.families.index(where: {$0.id == family.id}) {
            store.state.FamilyState.families[index] = family
        }
    }
}
