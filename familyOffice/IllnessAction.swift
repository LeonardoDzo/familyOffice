//
//  IllnessAction.swift
//  familyOffice
//
//  Created by Nan Montaño on 30/nov/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

enum IllnessAction : description {
    case getById(uid: String),
    getByUser(user: String),
    update(entity: IllnessEntity),
    create(entity: IllnessEntity),
    loading,
    none
    
    init() {
        self = .none
    }
}
