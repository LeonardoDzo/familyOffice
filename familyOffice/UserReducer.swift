//
//  UserReducer.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

//import Foundation
//import ReSwift
//import FirebaseAuth
//struct UserReducer {
//    func handleAction(action: Action, state: UserState?) -> UserState {
//        var state = state ?? UserState(users: [], user: nil, status: .none)
//
//        switch action {
//        case let action as GetUserAction:
//            state.status = .loading
//            if action.uid != nil {
//                getUser(action.uid)
//            }else if action.phone != nil {
//                service.USER_SVC.getUser(byphone: action.phone)
//            }
//
//            break
//        case let action as SetUserAction:
//            state.status = .finished
//            if action.user != nil {
//                let user = action.user
//                if user?.id == Auth.auth().currentUser?.uid {
//                    state.user = user
//                }else{
//                    if !state.users.contains(where: {$0.id == user?.id}) {
//                        state.users.append(user!)
//                    }
//                }
//            }
//            break
//        case let action as LoginAction:
//            if action.credential != nil{
//                service.AUTH_SERVICE.login(credential: action.credential)
//            }else if action.password != nil && action.username != nil {
//                service.AUTH_SERVICE.login(email: action.username, password: action.password)
//            }else{
//                break
//            }
//            state.status = .loading
//            break
//        case let action as CreateUserAction:
//            if action.user != nil {
//                service.USER_SVC.create(user: action.user)
//                state.status = .loading
//            }
//            break
//        case let action as UpdateUserAction:
//            if action.user != nil {
//                service.USER_SVC.update(user: action.user, image: action.img)
//                state.status = .loading
//            }
//            break
//        case let action as ChangePassUserAction:
//            if action.pass != nil  {
//                service.USER_SVC.changePassword(newPass: action.pass, oldPass: action.oldPass)
//                state.status = .loading
//            }
//            break
//        default:
//            break
//        }
//        return state
//    }
//
//    func getUser(_ uid: String) -> Void {
//        service.USER_SVC.valueSingleton(ref: ref_users(uid: uid))
//    }
//
//}

