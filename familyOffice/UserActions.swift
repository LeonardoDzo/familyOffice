//
//  UserActions.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder
import FirebaseAuth
let userActionTypeMap: TypeMap = [GetUserAction.type: GetUserAction.self,
                                  LoginAction.type: LoginAction.self,
                                  ChangePassUserAction.type: ChangePassUserAction.self]

struct GetUserAction: StandardActionConvertible {
    static let type = "USER_ACTION_GET"
    var uid: String!
    var phone: String!
    init(uid: String) {
        self.uid = uid
    }
    init(phone: String) {
        self.phone = phone
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertGoalAction.type, payload: [:], isTypedAction: true)
    }
}
struct CreateUserAction: StandardActionConvertible {
    static let type = "USER_ACTION_CREATE"
    var user: User!
    init(user: User) {
        self.user = user
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertGoalAction.type, payload: [:], isTypedAction: true)
    }
}
struct UpdateUserAction: StandardActionConvertible {
    static let type = "USER_ACTION_UPDATE"
    var img: UIImage?
    var user: User!
    init(user: User, img: UIImage? = nil) {
        self.user = user
        self.img = img
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertGoalAction.type, payload: [:], isTypedAction: true)
    }
}
struct ChangePassUserAction: StandardActionConvertible {
    static let type = "USER_ACTION_PASS"
    var pass: String!
    var oldPass: String!
    init(pass: String, oldPass: String) {
        self.pass = pass
        self.oldPass = oldPass
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: ChangePassUserAction.type, payload: [:], isTypedAction: true)
    }
}

struct LoginAction: StandardActionConvertible {
    static let type = "USER_ACTION_LOGIN"
    var username: String!
    var password: String!
    var credential: FIRAuthCredential! = nil
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    init(with credential: FIRAuthCredential) {
        self.credential = credential
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: LoginAction.type, payload: [:], isTypedAction: true)
    }
}


