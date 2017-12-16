//
//  UserS.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Firebase
import RealmSwift

class UserS : Action, EventProtocol {
    
    
    typealias EnumType = UserAction
    var id:  String! = UUID().uuidString
    var handles: [(String, UInt, DataEventType)] = []
    var action = UserAction()
    var status: Result<Any> = Result.loading
    var fromView: RoutingDestination! = .none
    
    
    convenience init(_ action: UserAction) {
        self.init()
        self.action = action
        self.fromView = RoutingDestination(rawValue: UIApplication.topViewController()?.restorationIdentifier ?? "" )
    }
    
    func selectFamily(family: FamilyEntity) -> Void {
        Constants.FirDatabase.REF_USERS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["familyActive" : family.id], withCompletionBlock: { (error, ref) in
                if error == nil {
                    self.status = .Finished(self.action)
                }else{
                      self.status = .Failed(self.action)
                }
                store.dispatch(self)
            })
        
    }
    func getUsersByFamilyActive() -> Void {
        verifyUser { (user, exist) in
            if exist {
                if let family = store.state.FamilyState.families.family(fid: (user.familyActive)!) {
                    for item in (family.members)! {
                        store.dispatch( UserS(.getbyId(uid: item)))
                    }
                }
            }
        }
    }
    
    func getUser(byphone phone: String) -> Void {
        let phone = phone.suffix(10)
        Constants.FirDatabase.REF_USERS.queryOrdered(byChild: "phone").queryEqual(toValue: phone).observeSingleEvent(of: .childAdded, with: {snapshot in
            if(snapshot.exists()){
                
                self.status = .Finished(self.action)
                self.routing(snapshot: snapshot, action: .value, ref: "users/")
            }else{
                self.status = .Failed(self.action)
                store.dispatch(self)
            }
        })
    }
    func create(user: UserEntity) -> Void {
        
        if var userJson =  user.toJSON() {
            userJson["families"] = user.families.toNSArrayByKey(ofType: String.self) ?? []
            userJson["events"] = user.events.toNSArrayByKey(ofType: String.self) ?? []
            userJson["tokens"] = user.tokens.toNSArrayByKey(ofType: String.self) ?? []
            self.insert("users/\(user.id)", value: userJson, callback: { ref in
                if ref is DatabaseReference {
                    self.status = .Finished(user)
                    rManager.save(objs: user)
                    store.dispatch(self)
                }
            })
        }else{
            print("Algo salio mal al crear usuario")
            status = .failed
            store.dispatch(self)
        }
    }
    
    func update(user: UserEntity, image: UIImage? ) -> Void {
        let user = user
        let ref = "users/\(user.id)"
        
        if image != nil {
            let imageName = NSUUID().uuidString
            service.STORAGE_SERVICE.insert("users/\(user.id)/images/\(imageName).png", value: image! , callback: {(response) in
                if let metadata = response as? StorageMetadata {
                    try! rManager.realm.write {
                        user.photoURL = (metadata.downloadURL()?.absoluteString)!
                        self.action = .update(user: user, img: nil)
                    }
                }else{
                    self.status = .Failed(self.action)
                }
                store.dispatch(self)
            })
        }else{
            self.update(ref, value: user.toJSON()!, callback: { ref in
                if ref is DatabaseReference {
                    self.status = .Finished(self.action)
                }else{
                    self.status = .Failed(self.action)
                }
                store.dispatch(self)
            })
        }
    }
    
    func initObserves(ref: String, actions: [DataEventType]) -> Void {
        for action in actions {
            if !handles.contains(where: { $0.0 == ref && $0.2 == action} ){
                self.child_action(ref: ref, action: action)
            }
        }
    }
}

extension UserS : RequestProtocol {
    func removed(snapshot: DataSnapshot) {
        
    }
    func notExistSnapshot() {
        if case UserAction.getbyId(let uid) = self.action {
            if Auth.auth().currentUser?.uid == uid, let user = Auth.auth().currentUser {
                let newuser = UserEntity()
                newuser.id = user.uid
                newuser.name = user.displayName!
                newuser.email = user.email!
                newuser.photoURL = user.photoURL?.absoluteString ?? ""
                store.dispatch(UserS(.create(user: newuser)))
            }
        }
    }
    func added(snapshot: DataSnapshot) {
        do {
            if let snapshotValue = snapshot.value as? NSDictionary {
                if let data = snapshotValue.jsonToData() {
                    let user = try JSONDecoder().decode(UserEntity.self, from: data)
                    
                    self.status = .Finished(action)
                    rManager.save(objs: user)
                    store.dispatch(self)
                    
                    if user.isUserLogged() {
                        
                        for fid in user.families  {
                           store.dispatch(FamilyS(.getbyId(fid: fid.value)))
                        }
                        
                        for eid in user.events {
                            store.dispatch(EventSvc(.get(byId: eid.value)))
                        }
                        
                        service.NOTIFICATION_SERVICE.removeHandles()
                        service.NOTIFICATION_SERVICE.initObserves(ref: "notifications/\(user.id)", actions: [.childAdded])
                       
                        let ref = "\(ref_users(uid: user.id))/families"
                        sharedMains.removeHandles(ref: ref)
                        sharedMains.initObserves(ref:ref, actions: [.childAdded, .childRemoved])
                    }
                    let ref = "\(ref_users(uid: user.id))"
                    sharedMains.removeHandles(ref: ref)
                    sharedMains.initObserves(ref:ref, actions: [.childChanged])
                    if let refreshedToken = InstanceID.instanceID().token() {
                         store.dispatch(UserS(.updateToken(token: refreshedToken)))
                    }
                    
                }
            }
        }catch let error {
            print(error)
            self.status = .Failed(error)
            store.dispatch(self)
        }
        
        
    }
    func removed(snapshot: Any, id: Any) {
        
    }
    func updated(snapshot: DataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4]
        self.action = .getbyId(uid: id)
        self.status = .loading
        store.dispatch(self)
    }
    
    func update(_ token: String) {
        if let user = familyOffice.getUser() {
            self.update("users/\(user.id)/tokens", value: [token: true], callback: { (error) in
                if error is DatabaseReference {
                    self.status = .Finished(self.action)
                }else{
                    self.status = .Failed(self.action)
                }
            })
            
        }
    }


}

extension UserS : Reducer {
    typealias StoreSubscriberStateType = UserState
    
    func handleAction(state: UserState?) -> UserState {
        var state = state ?? UserState(users: .none, user: .none)
        state.user = self.status
        switch status {
        case .loading, .Loading(_):
           
            switch self.action {
                
            case .getbyId(let uid):
                self.valueSingleton(ref: ref_users(uid: uid))
                break
            case .getbyPhone(let phone):
                self.getUser(byphone: phone)
                break
            case .set(let user):
                if Auth.auth().currentUser?.uid == user.id {
                    state.user = .Finished(user)
                }else{
                    if case .Finished(var value as [User]) = state.users {
                        if let index = value.index(where: {$0.id == user.id}) {
                            value[index] = user
                        }else{
                            value.append(user)
                        }
                        state.users = .Finished(value)
                    }
                }
                break
            case .update(let user, let img):
                self.update(user: user, image: img)
                break
            case .updateToken(let token):
                self.update(token)
                break
            case .create(let user):
                self.create(user: user)
                break
            case .selectFamily(let family):
                self.selectFamily(family: family)
                break
            case .none:
                break
            }
            break
        case .failed, .Failed(_):
              state.user = self.status
            break
        case .finished, .Finished(_):
            
              state.user = self.status
             break
         case .noFamilies, .none:
            break
        }
        
        return state
    }
    
    
    
}
