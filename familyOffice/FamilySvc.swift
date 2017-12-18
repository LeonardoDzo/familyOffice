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
    var handles: [(String, UInt, DataEventType)] = []
    private static let instance : FamilySvc = FamilySvc()
    private init() {
    }
    
    public static func Instance() -> FamilySvc {
        return instance
    }
    
    func initObserves(ref: String, actions: [DataEventType]) -> Void {
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

    func addHandle(_ handle: UInt, ref: String, action: DataEventType) {
        self.handles.append((ref,handle,action))
    }
    func inserted(ref: DatabaseReference) {
        //store.state.FamilyState.status = .finished
    }
    func routing(snapshot: DataSnapshot, action: DataEventType, ref: String) {
       
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
        family.setId()
        let ref = "families/\(family.id!)"
        let imageName = NSUUID().uuidString
        service.STORAGE_SERVICE.insert("families/\(family.id!)/images/\(imageName).jpg", value: data , callback: {(response) in
            if let metadata = response as? StorageMetadata {
                family.photoURL = metadata.downloadURL()?.absoluteString
                family.imageProfilePath = metadata.path
                self.insert(ref, value: family.toDictionary(), callback: { (response) in
                    if response is DatabaseReference {
                        store.state.FamilyState.status = .finished
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
            service.STORAGE_SERVICE.insert("families/\(family.id!)/images/\(imageName).jpg", value: data! , callback: {(response) in
                if let metadata = response as? StorageMetadata {
                    family.photoURL = metadata.downloadURL()?.absoluteString
                    family.imageProfilePath = metadata.path
                    store.dispatch(UpdateFamilyAction(family: family, img: nil))
                }else{
                    store.state.FamilyState.status = .failed
                }
            })
        }else{
            self.update(ref, value: family.toDictionary() as! [AnyHashable: Any], callback: { ref in
                if ref is DatabaseReference {
                    store.state.FamilyState.status = .finished
                }
            })
        }
    }
}

extension FamilySvc: repository {
    func notExistSnapshot(ref: String) {
        
    }
    
    func added(snapshot: DataSnapshot) {
        let family : Family = Family(snapshot: snapshot)
        if !store.state.FamilyState.families.hasEqualContent(family){
            store.state.FamilyState.families.appendItem(family)
        }else{
            if let index = store.state.FamilyState.families.indexOf(fid: family.id!){
                store.state.FamilyState.families.items[index] = family
            }
        }
    }
    func removed(snapshot: DataSnapshot) {
        let key : String = snapshot.key
        store.state.FamilyState.families.removeItem(fid: key)
        if userStore?.familyActive == key {
            if let family = store.state.FamilyState.families.items.first {
               // service.USER_SVC.selectFamily(family: family)
            }
            
        }
    }
    
    func updated(snapshot: DataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        if let index = store.state.FamilyState.families.indexOf(fid: id){
            store.state.FamilyState.families.items[index].update(snapshot: snapshot)
        }
    }
}
