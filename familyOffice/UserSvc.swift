//
//  UserSvc.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase
class UserSvc {
    var handles: [(String, UInt, FIRDataEventType)] = []
    
    private init(){
    }
    public static func Instance() -> UserSvc {
        return instance
    }
    func initObserves(ref: String, actions: [FIRDataEventType]) -> Void {
        for action in actions {
            if !handles.contains(where: { $0.0 == ref && $0.2 == action} ){
                self.child_action(ref: ref, action: action)
            }
        }
    }
    
    private static let instance : UserSvc = UserSvc()
    
    func selectFamily(family: Family) -> Void {
        Constants.FirDatabase.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).updateChildValues(["familyActive" : family.id])
        getUsersByFamilyActive()
    }
    func getUsersByFamilyActive() -> Void {
        let user = store.state.UserState.user
        let family = store.state.FamilyState.families.first(where: {$0.id == user?.familyActive})
        for item in (family?.members)! {
            store.dispatch(GetUserAction(uid: item))
        }
    }
}
extension UserSvc : RequestService {
    func notExistSnapshot() {
        
    }

    func addHandle(_ handle: UInt, ref: String, action: FIRDataEventType) {
        self.handles.append((ref,handle,action))
    }
    
    func inserted(ref: FIRDatabaseReference) {
        store.state.UserState.status = .finished
    }
    
    func routing(snapshot: FIRDataSnapshot, action: FIRDataEventType, ref: String) {
        if ref.components(separatedBy: "/").count > 2 {
            actionFamily(snapshot: snapshot, action: action)
            return
        }
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
    func actionFamily(snapshot: FIRDataSnapshot, action: FIRDataEventType) -> Void {
        switch action {
        case .childAdded:
            service.FAMILY_SVC.valueSingleton(ref: ref_family(snapshot.key))
            break
        case .childRemoved:
            service.FAMILY_SVC.removed(snapshot: snapshot)
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

extension UserSvc : repository {
    /// Este metodo guarda al usuario, verificando si es el usuario logeado guardandolo en el state UserState.user,
    /// los demas los guarda en UserState.users
    /// - Parameter snapshot: FirDataSnapshot
    func added(snapshot: FIRDataSnapshot) {
        let user = User(snapshot: snapshot)
        if user.id == FIRAuth.auth()?.currentUser?.uid {
            store.state.UserState.user = user
            service.NOTIFICATION_SERVICE.saveToken()
            self.initObserves(ref: "users/\(user.id!)/families", actions: [.childAdded, .childRemoved])
        }else{
            if !store.state.UserState.users.contains(where: {$0.id == user.id}) {
                store.state.UserState.users.append(user)
            }
        }
        self.initObserves(ref: ref_users(uid: user.id!), actions: [.childChanged])
        store.state.UserState.status = .finished
    }
    func updated(snapshot: FIRDataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4]
        if id == FIRAuth.auth()?.currentUser?.uid {
            store.state.UserState.user?.update(snapshot: snapshot)
        }else if let index = store.state.UserState.users.index(where: {$0.id == id})  {
            store.state.UserState.users[index].update(snapshot: snapshot)
        }
    }
    func removed(snapshot: FIRDataSnapshot) {
        
    }
}
