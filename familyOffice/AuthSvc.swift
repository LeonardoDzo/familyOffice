//
//  AuthSvc.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Firebase
import RealmSwift

enum AuthAction {
    case changePass(pass: String, oldPass: String),
    login(username: String, password: String),
    loginWithCredentials(credential: AuthCredential),
    logout,
    none
    init(){
        self = .none
    }
}


@objcMembers
class AuthSvc : Object, Action, EventProtocol {
    typealias EnumType = AuthAction
    dynamic var id : String!
    dynamic var action = AuthAction()
    dynamic var handles: [(String, UInt, DataEventType)] = []
    dynamic var status: Result<Any>! = .none
    dynamic var fromView: RoutingDestination! = .none
    
    primaryKey
    convenience required init() {
        self.init()
        self.fromView = RoutingDestination(rawValue: UIApplication.topViewController()?.restorationIdentifier ?? "" )
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
    

    func login(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if((error) != nil){
                self.status = .Failed(error.debugDescription)
            }else{
                self.status = .finished
            }
            store.dispatch(self)
        }
    }
    func login(credential:AuthCredential){
        Auth.auth().signIn(with: credential ) { (user, error) in
            if((error) != nil){
                self.status = .Failed(error.debugDescription)
            }else{
                self.status = .finished
            }
            store.dispatch(self)
        }
    }
    func logOut(){
        store.state = nil
        rManager.deleteDatabase()
        try! Auth.auth().signOut()
    }
}
extension AuthSvc : Reducer {
    typealias StoreSubscriberStateType = AuthState
    func handleAction(state: AuthState?) -> AuthState {
        if case self.status = Result<Any>.loading {
            switch self.action {
                case .changePass(let pass, let oldPass):
                    self.changePassword(newPass: pass, oldPass: oldPass)
                break
                case .login(let username, let password):
                    self.login(email: username, password: password)
                break
                case .loginWithCredentials(let credential):
                    self.login(credential: credential)
                break
                case .none:
                break
                case .logout:
                    self.logOut()

                break
            }
        }else{
            
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
}
