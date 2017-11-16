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
    var handles: [(String, UInt, DataEventType)] = []
    
    private init(){
    }
    public static func Instance() -> UserSvc {
        return instance
    }
    func initObserves(ref: String, actions: [DataEventType]) -> Void {
        for action in actions {
            if !handles.contains(where: { $0.0 == ref && $0.2 == action} ){
                self.child_action(ref: ref, action: action)
            }
        }
    }
    
    private static let instance : UserSvc = UserSvc()
    
    func selectFamily(family: Family) -> Void {
        Constants.FirDatabase.REF_USERS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["familyActive" : family.id])
        getUsersByFamilyActive()
    }
    func getUsersByFamilyActive() -> Void {
        verifyUser { (user, exist) in
            if exist {
                if let family = store.state.FamilyState.families.family(fid: (user.familyActive)!) {
                    for item in (family.members)! {
                        store.dispatch(UserAction.getbyId(uid: item))
                    }
                }
            }
        }
        
        
    }
    
    func getUser(byphone phone: String) -> Void {
        Constants.FirDatabase.REF_USERS.queryOrdered(byChild: "phone").queryEqual(toValue: phone).observeSingleEvent(of: .childAdded, with: {snapshot in
            if(snapshot.exists()){
                let user = User(snapshot: snapshot)
                store.dispatch(UserAction.set(user: user))
            }
        })
    }

    
    func create(user: User) -> Void {
        self.insert("users/\(user.id)", value: user.toDictionary(), callback: { ref in
            if ref is DatabaseReference {
                store.dispatch(UserAction.set(user: user))
            }
        })
    }
    func changePassword(newPass: String, oldPass: String) -> Void {
        let user = Auth.auth().currentUser
        Auth.auth().signIn(withEmail: (user?.email)!, password: oldPass) { (user, error) in
            if((error) != nil){
                store.state.UserState.user = .failed
            }else{
                user?.updatePassword(to: newPass) { error in
                    if let error = error {
                        print(error.localizedDescription)
                         store.state.UserState.user = .failed
                    } else {
                        store.state.UserState.user = .finished
                    }
                }
            }
            
        }
    }
}
extension UserSvc : RequestService {
        func notExistSnapshot() {
            if let user = Auth.auth().currentUser {
                service.AUTH_SERVICE.createAccount(user: user)
            }
           
        }
        
        func addHandle(_ handle: UInt, ref: String, action: DataEventType) {
            self.handles.append((ref,handle,action))
        }
        
        func inserted(ref: DatabaseReference) {
            store.state.UserState.user = .finished
        }
        
        func routing(snapshot: DataSnapshot, action: DataEventType, ref: String) {
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
        func actionFamily(snapshot: DataSnapshot, action: DataEventType) -> Void {
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
        func update(user: User, image: UIImage? ) -> Void {
            var user = user
            let ref = "users/\(user.id!)"
            
            if image != nil {
                let imageName = NSUUID().uuidString
                service.STORAGE_SERVICE.insert("users/\(user.id!)/images/\(imageName).png", value: image! , callback: {(response) in
                    if let metadata = response as? StorageMetadata {
                        user.photoURL = metadata.downloadURL()?.absoluteString
                        store.dispatch(UserAction.update(user: user, img: nil))
                    }else{
                        store.dispatch(UserAction.set(user: user))
                    }
                })
            }else{
                self.update(ref, value: user.toDictionary() as! [AnyHashable: Any], callback: { ref in
                    if ref is DatabaseReference {
                       store.dispatch(UserAction.set(user: user))
                    }
                })
            }
        }
        
        func delete(_ ref: String, callback: @escaping ((Any) -> Void)) {
        }
    }
    
    extension UserSvc : repository {
        /// Este metodo guarda al usuario, verificando si es el usuario logeado guardandolo en el state UserState.user,
        /// los demas los guarda en UserState.users
        /// - Parameter snapshot: FirDataSnapshot
        func added(snapshot: DataSnapshot) -> Void {
            let user = User(snapshot: snapshot)
            store.dispatch(UserAction.set(user: user))
            
            if user.id == Auth.auth().currentUser?.uid {
                if user.families != nil {
                    for fid in (user.families?.allKeys)!  {
                        service.FAMILY_SVC.valueSingleton(ref: "families/\(fid)")
                    }
                }
                service.NOTIFICATION_SERVICE.removeHandles()
                service.NOTIFICATION_SERVICE.initObserves(ref: "notifications/\(user.id!)", actions: [.childAdded])
                service.USER_SVC.initObserves(ref: "users/\(user.id!)/families", actions: [.childAdded, .childRemoved])
            }
            self.initObserves(ref: ref_users(uid: user.id!), actions: [.childChanged])
        }
        func updated(snapshot: DataSnapshot, id: Any) {
            let id = snapshot.ref.description().components(separatedBy: "/")[4]
            if var user = store.state.UserState.findUser(byId: id) {
                user.update(snapshot: snapshot)
                store.dispatch(UserAction.set(user: user))
            }
        }
        func removed(snapshot: DataSnapshot) {
            
        }
}
