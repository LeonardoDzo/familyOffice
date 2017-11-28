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
         update(user: UserEntitie, img: UIImage?),
         create(user: UserEntitie),
         selectFamily(family: FamilyEntitie),
         none
    
    init(){
        self = .none
    }
}
