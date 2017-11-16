//
//  UserActions.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import FirebaseAuth

protocol Reducer {
    associatedtype StoreSubscriberStateType
    func handleAction(state: StoreSubscriberStateType?) -> StoreSubscriberStateType
}

enum UserAction : Action {
    case getbyId(uid: String),
         getbyPhone(phone: String),
         set(user: User),
         update(user: User, img: UIImage?),
         changePass(pass: String, oldPass: String),
         login(username: String, password: String),
         loginWithCredentials(credential: AuthCredential),
         create(user: User),
         authFai(error:String)
    
}
extension UserAction :  Reducer {
    typealias StoreSubscriberStateType = UserState
    
    func handleAction(state: UserState?) -> UserState {
        var state = state ?? UserState(users: .none, user: .none)
        switch self {
        case .getbyId(let uid):
            service.USER_SVC.valueSingleton(ref: ref_users(uid: uid))
            break
        case .getbyPhone(let phone):
            service.USER_SVC.getUser(byphone: phone)
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
            service.USER_SVC.update(user: user, image: img)
            break
        case .changePass(let pass, let oldPass):
            service.USER_SVC.changePassword(newPass: pass, oldPass: oldPass)
            break
        case .login(let username, let password):
            service.AUTH_SERVICE.login(email: username, password: password)
            break
        case .loginWithCredentials(let credential):
            service.AUTH_SERVICE.login(credential: credential)
            break
        case .create(let user):
            service.USER_SVC.create(user: user)
            break
        case .authFai(let error):
            state.user = .Failed(error)
            break
        }
        return state
    }
   
}
