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


struct GetUserAction: Action {
    var uid: String!
    var phone: String!
    init(uid: String) {
        self.uid = uid
    }
    init(phone: String) {
        self.phone = phone
    }
}
struct SetUserAction: Action {
    var user: User!
    init(u: User) {
        self.user = u
    }
}
struct CreateUserAction: Action {
    var user: User!
    init(user: User) {
        self.user = user
    }
}
struct UpdateUserAction: Action {
    var img: UIImage?
    var user: User!
    init(user: User, img: UIImage? = nil) {
        self.user = user
        self.img = img
    }
}
struct ChangePassUserAction: Action {
    var pass: String!
    var oldPass: String!
    init(pass: String, oldPass: String) {
        self.pass = pass
        self.oldPass = oldPass
    }
}

struct LoginAction: Action {
    var username: String!
    var password: String!
    var credential: AuthCredential! = nil
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    init(credential: AuthCredential) {
        self.credential = credential
    }
}


