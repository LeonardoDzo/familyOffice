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
var isRegisterWithCredentials = false
protocol description {
}
extension description {
    var description: String {
        let mirror = Mirror(reflecting: self)
        var result = ""
        for child in mirror.children {
            if let label = child.label {
                result += "\(label): \(child.value)"
            } else {
                result += "\(child.value)"
            }
        }
        return result
    }
}

enum AuthAction: description  {
    case changePass(pass: String, oldPass: String),
    login(username: String, password: String),
    loginWithCredentials(credential: AuthCredential),
    logout,
    registerUser(user: UserEntity, pass: String),
    none
    init(){
        self = .none
    }
}

class AuthSvc : Action, EventProtocol {

    
    func getDescription() -> String {
        return "\(self.action.description) \(self.status.description)"
    }
    
  
    typealias EnumType = AuthAction
    var id : String! = UUID().uuidString
    var action = AuthAction()
    var handles: [(String, UInt, DataEventType)] = []
    var status: Result<Any> = .loading
    var fromView: RoutingDestination! = .none
    
    init() {
        self.status = .none
    }
    
    convenience required init(_ action: AuthAction) {
        self.init()
        self.action = action
        status = .loading
        self.fromView = RoutingDestination(rawValue: UIApplication.topViewController()?.restorationIdentifier ?? "" )
    }
    
    func changePassword(newPass: String, oldPass: String) -> Void {
        let user = Auth.auth().currentUser
        Auth.auth().signIn(withEmail: (user?.email)!, password: oldPass) { (user, error) in
            if((error) != nil){
                self.status = .failed
            }else{
                user?.updatePassword(to: newPass) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        self.status = .failed
                    } else {
                         self.status = .finished
                    }
                }
            }
             store.dispatch(self)
            
        }
    }
    
    
    func login(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if((error) != nil){
                self.status = .Failed(error.debugDescription)
            }else{
                rManager.deleteDatabase()
                self.status = .finished
            }
            store.dispatch(self)
        }
    }
    func login(credential:AuthCredential){
        isRegisterWithCredentials = true
        Auth.auth().signIn(with: credential ) { (user, error) in
            if((error) != nil){
                self.status = .Failed(error.debugDescription)
            }else{
                rManager.deleteDatabase()
                self.status = .finished
            }
            store.dispatch(self)
        }
    }
    func logOut(){
        try! Auth.auth().signOut()
        self.status = .Finished(action)
        store.state.authState.state = self.status
        if let top = UIApplication.topViewController() {
            top.popToView(view: .start)
        }
    }
    
}
extension AuthSvc : Reducer {
    typealias StoreSubscriberStateType = AuthState

    fileprivate func registerUser(_ user: UserEntity, _ pass: String) {
        let newuser = user
        isRegisterWithCredentials = false
        Auth.auth().createUser(withEmail: user.email, password: pass) { (user, error) in
            if(error == nil){
                newuser.id = user!.uid
                self.status = .Finished(self.action)
                store.dispatch(UserS(UserAction.create(user: newuser)))
            }else{
                self.status = .Failed(self.action)
            }
            store.dispatch(self)
        }
    }
    
    func handleAction(state: AuthState?) -> AuthState {
        var state = state ?? AuthState(state: .none)
        state.state = self.status
        switch status {
        case .loading, .Loading(_):
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
            case .registerUser(let user, let pass):
                registerUser(user, pass)
                break
            case .none:
                break
            case .logout:
                self.logOut()
                break
            }
        case .Failed(_), .failed:
            break
        case .finished, .Finished(_):
            if case .changePass(_,_) = self.action {
            }
            break
        case .noFamilies, .none:
            break
        }
        return state
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
