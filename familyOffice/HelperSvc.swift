//
//  HelperSvc.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 16/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
/// Global User
var userStore = {
    return store.state.UserState.getUser()
}()

/// Verifica si existe información del usuario antes de ejecutar una func que lo ocupe
///
/// - Parameter closure: Codigo a ejecutar despues de verificar al usuario
func verifyUser( closure: @escaping (_ user: User, _ exist: Bool)->()) {
    DispatchQueue.main.async {
        if let user = store.state.UserState.getUser() {
            userStore = store.state.UserState.getUser()
            closure(user, true)
        }else{
            closure(User(), false)
        }
    }
}



