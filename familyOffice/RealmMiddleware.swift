//
//  RealmMiddleware.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift
import ReSwift


let realmMiddleware: Middleware<Any> = { dispatch, getState in
    return { next in
        return { action in
            if let s = action as? EventDescription {
                rManager.save(objs: EventProccess(builder: s))
            }
            // call next middleware
            return next(action)
        }
    }
}
