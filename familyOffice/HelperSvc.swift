//
//  HelperSvc.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 16/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

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
func isAuth()  {
    var view = false
    Auth.auth().addStateDidChangeListener { auth, user in
        
        if (user != nil) {
            checkUserAgainstDatabase(completion: {(success, error ) in
                if success {
                    if !view {
                        store.dispatch(UserS(.getbyId(uid: (user?.uid)!)))
                        view = !view
                    }
                }else{
                    store.dispatch(AuthSvc(.logout))
                }
            })
        }else{
            store.dispatch(AuthSvc(.logout))
        }
    }
}

func checkUserAgainstDatabase(completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
    guard let currentUser = Auth.auth().currentUser else { return }
    currentUser.getIDTokenForcingRefresh(true) { (idToken, error) in
        if let error = error {
            completion(false, error as NSError?)
            print(error.localizedDescription)
        } else {
            completion(true, nil)
        }
    }
}

