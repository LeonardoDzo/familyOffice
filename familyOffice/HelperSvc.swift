//
//  HelperSvc.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 16/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

/// Global User
var userStore = {
    return store.state.UserState.getUser()
}()

/// Verifica si existe información del usuario antes de ejecutar una func que lo ocupe
///
/// - Parameter closure: Codigo a ejecutar despues de verificar al usuario
func verifyUser( closure: @escaping (_ user: User, _ exist: Bool)->()) {
    DispatchQueue.main.async {
        if let user = store.state.UserState.getUser() {
            closure(user, true)
        }else{
            closure(User(), false)
        }
    }
}

func getUser () -> UserEntity? {
   
    if let user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: Auth.auth().currentUser?.uid) {
        return user
    }
    return nil
}

func isAuth()  {
    var view = false
    Auth.auth().addStateDidChangeListener { auth, user in
        
        if (user != nil) {
            checkUserAgainstDatabase(completion: {(success, error ) in
                if success {
                    if !view {
                        store.dispatch(UserS(.getbyId(uid: (user?.uid)!)))
                        view = !view
                    }
                }else{
                    if case .loading = store.state.authState.state {
                    }else{
                        store.dispatch(AuthSvc(.logout))
                    }
                }
            })
        }
    }
}

func checkUserAgainstDatabase(completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
    guard let currentUser = Auth.auth().currentUser else { return }
    currentUser.getIDTokenForcingRefresh(true) { (idToken, error) in
        if let error = error {
            completion(false, error as NSError?)
            print(error.localizedDescription)
        } else {
            completion(true, nil)
        }
    }
}
let sharedMains = MainFunctions.sharedInstance
class MainFunctions : RequestProtocol {
    func notExistSnapshot(ref: String) {
    }
    
    var handles = [(String, UInt, DataEventType)]()
    
    static let sharedInstance = MainFunctions()
    
    private init(){
    }
    func initObserves(ref: String, actions: [DataEventType]) -> Void {
        for action in actions {
            if !handles.contains(where: { $0.0 == ref && $0.2 == action} ){
                self.child_action(ref: ref, action: action)
            }
        }
    }

    func added(snapshot: DataSnapshot) {
        let route = snapshot.ref.description().components(separatedBy: "/")
        switch route[3] {
            case "users":
                switch route[5]{
                    case "families":
                        store.dispatch(FamilyS(.getbyId(fid: route[6])))
                        break
                    case "events":
                         store.dispatch(EventSvc(.get(byId: route[6])))
                        break
                    default:
                        break
                }
            break
            default:
                break
        }
    }
    
    func updated(snapshot: DataSnapshot, id: Any) {
        let route  = snapshot.ref.description().components(separatedBy: "/")
        switch route[3] {
        case "users":
            let id = snapshot.ref.description().components(separatedBy: "/")[4]
           
            if  let user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: id) {
                if let val = snapshot.value {
                    let snapshot : Dictionary<String, Any> = [route[5]: val ]
                    if user.update(snap: snapshot) {
                        store.state.UserState.user = .finished
                    }
                }
            }
            break
        case "families":
            let id = snapshot.ref.description().components(separatedBy: "/")[4]
            if let family = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: id) {
                if let val = snapshot.value {
                    let snapshot : Dictionary<String, Any> = [route[5]: val ]
                    if family.update(snap: snapshot) {
                        store.state.FamilyState.status = .finished
                    }
                }
            }
            break
        case "events":
            let id = snapshot.ref.description().components(separatedBy: "/")[4]
            store.dispatch(EventSvc(.get(byId: id)))
            break
        default:
            break
        }
        
    }
    
    func removed(snapshot: DataSnapshot) {
        let route = snapshot.ref.description().components(separatedBy: "/")
        switch route[4] {
        case "users":
            switch route[5]{
            case "families":
                store.dispatch(FamilyS(.delete(fid: route[6])))
                break
            case "events":
                EventSvc().removeHandles(ref: snapshot.ref.description())
                if let event = rManager.realm.object(ofType: EventEntity.self, forPrimaryKey:  route[6]) {
                    store.dispatch(EventSvc(.delete(eid:event)))
                }
                
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
    
    func notExistSnapshot() {
        
    }
    
    
}

