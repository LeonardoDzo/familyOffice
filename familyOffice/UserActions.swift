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

enum UserAction : description {
    case getbyId(uid: String,assistant: Bool),
         getbyPhone(phone: String),
         set(user: User),
         update(user: UserEntity, img: UIImage?),
         create(user: UserEntity),
         selectFamily(family: FamilyEntity),
         updateToken(token: String),
         none
    
    init(){
        self = .none
    }
}
