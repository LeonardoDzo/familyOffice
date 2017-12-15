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
    case getbyId(uid: String),
         getbyPhone(phone: String),
         set(user: User),
         update(user: UserEntity, img: UIImage?),
         create(user: UserEntity),
         selectFamily(family: FamilyEntity),
         none
    
    init(){
        self = .none
    }
}
