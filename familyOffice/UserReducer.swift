//
//  UserReducer.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct UserReducer: Reducer {
    func handleAction(action: Action, state: UserState?) -> UserState {
        var state = state ?? UserState(users: [], user: nil, status: .none)
        
        switch action {
        case let action as GetUserAction:
            if action.uid != nil {
                getUser(action.uid)
            }else if action.phone != nil {
                service.USER_SVC.getUser(byphone: action.phone)
            }
            state.status = .loading
            break
        case let action as LoginAction:
            if action.credential != nil{
                service.AUTH_SERVICE.login(credential: action.credential)
            }else if action.password != nil && action.username != nil {
                service.AUTH_SERVICE.login(email: action.username, password: action.password)
            }else{
                break
            }
            state.status = .loading
            break
        case let action as CreateUserAction:
            if action.user != nil {
                service.USER_SVC.create(user: action.user)
                state.status = .loading
            }
            break
        default:
            break
        }
        return state
    }
    
    func getUser(_ uid: String) -> Void {
        service.USER_SVC.valueSingleton(ref: ref_users(uid: uid))
    }
}
