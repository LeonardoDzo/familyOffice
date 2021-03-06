//
//  MedicineService.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/19/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase
class MedicineService: RequestService {
    func notExistSnapshot() {
        
    }
    
    
    func notExistSnapshot(ref: String) {
        
    }
    
    var medicines: [Medicine] = []
    var handles: [(String, UInt, DataEventType)] = []
    private init() {}
    
    static private let instance = MedicineService()
    
    public static func Instance() -> MedicineService { return instance }
    
    func routing(snapshot: DataSnapshot, action: DataEventType, ref: String) {
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
    
    func initObservers(ref: String, actions: [DataEventType]) -> Void {
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
        for handle in self.handles {
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    
    func inserted(ref: DatabaseReference) {
        Constants.FirDatabase.REF_FAMILIES.child((userStore?.familyActive)!)
            .child("medicines").updateChildValues([ref.key:true])
        
        store.state.MedicineState.status = .none
    }
    
    func create(_ nMedicine: Medicine) -> Void{
        let medicine = nMedicine
        verifyUser { (user, exist) in
            if exist {
                let id = user.familyActive!
                let path = "medicines/\(id)/\(medicine.id!)"
                
                service.MEDICINE_SERVICE.insert(path, value: medicine.toDictionary(), callback: {ref in
                    if ref is DatabaseReference {
                        store.state.MedicineState.medicines[id]?.append(medicine)
                    }
                })
            }
        }
    }
}

extension MedicineService: repository {
    func added(snapshot: DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let medicine = Medicine(snapshot: snapshot)
        
        if store.state.MedicineState.medicines[id] == nil {
            store.state.MedicineState.medicines[id] = []
        }
        
        if !(store.state.MedicineState.medicines[id]?.contains(where: {$0.id == medicine.id}))!{
            store.state.MedicineState.medicines[id]?.append(medicine)
        }
    }
    
    func updated(snapshot: DataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let medicine = Medicine(snapshot: snapshot)
        if let index = store.state.MedicineState.medicines[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.MedicineState.medicines[id]?[index] = medicine
        }
    }
    
    func removed(snapshot: DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        if let index = store.state.MedicineState.medicines[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.MedicineState.medicines[id]?.remove(at: index)
        }
    }
}
