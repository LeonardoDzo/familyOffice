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
    
    func exitFamily(family: Family, uid:String) -> Void {
        Constants.FirDatabase.REF_FAMILIES.child("/\((family.id)!)/members/\(uid)").removeValue()
    }
    
    func delete(family fid: String) {
        self.delete("families/\(fid)", callback: { deleted in
            if deleted {
                store.state.FamilyState.status = .failed
            }else{
                store.state.FamilyState.status = .finished
            }
        })
    }
    
    func create(family: Family, with data: UIImage) -> Void {
        var family = family
        let imageName = NSUUID().uuidString
        family.setId()
        service.STORAGE_SERVICE.insert("families/\(family.id!)/images/\(imageName).png", value: data , callback: {(response) in
            if let metadata = response as? FIRStorageMetadata {
                family.photoURL = metadata.downloadURL()?.absoluteString
                family.imageProfilePath = metadata.path
                let ref = "families/\(family.id!)"
                self.insert(ref, value: family.toDictionary(), callback: { (response) in
                    if response is String {
                        store.state.FamilyState.status = .finished
                        store.state.FamilyState.status = .none
                    }else{
                        store.state.FamilyState.status = .failed
                    }
                })
            }else{
                store.state.FamilyState.status = .failed
            }
            
        })
    }
    func update(family: Family, with data: UIImage?) -> Void {
        var family = family
        let ref = "families/\(family.id!)"
        
        if data != nil {
            let imageName = NSUUID().uuidString
            service.STORAGE_SERVICE.insert("families/\(family.id!)/images/\(imageName).png", value: data! , callback: {(response) in
                if let metadata = response as? FIRStorageMetadata {
                    family.photoURL = metadata.downloadURL()?.absoluteString
                    family.imageProfilePath = metadata.path
                    self.update(ref, value: family.toDictionary() as! [AnyHashable: Any], callback: { ref in
                        if ref is FIRDatabaseReference {
                            store.state.FamilyState.status = .finished
                            store.state.FamilyState.status = .none
                        }
                    })
                }else{
                    store.state.FamilyState.status = .failed
                }
            })
        }else{
            self.update(ref, value: family.toDictionary() as! [AnyHashable: Any], callback: { ref in
                if ref is FIRDatabaseReference {
                    store.state.FamilyState.status = .finished
                    store.state.FamilyState.status = .none
                }
            })
        }
    }
}

extension FamilySvc: repository {
    func added(snapshot: FIRDataSnapshot) {
        let family : Family = Family(snapshot: snapshot)
        if !store.state.FamilyState.families.hasEqualContent(family){
            store.state.FamilyState.families.appendItem(family)
        }else{
            if let index = store.state.FamilyState.families.indexOf(fid: family.id!){
                store.state.FamilyState.families.items[index] = family
            }
        }
    }
    func removed(snapshot: FIRDataSnapshot) {
        let key : String = snapshot.key
        store.state.FamilyState.families.removeItem(fid: key)
        if store.state.UserState.user?.familyActive == key {
            if let family = store.state.FamilyState.families.items.first {
                service.USER_SVC.selectFamily(family: family)
            }
            
        }
    }
    
    func updated(snapshot: FIRDataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        if let index = store.state.FamilyState.families.indexOf(fid: id){
            store.state.FamilyState.families.items[index].update(snapshot: snapshot)
        }
    }
}
