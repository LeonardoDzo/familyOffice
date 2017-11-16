//
//  AuthService.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 03/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import ReSwift
class AuthService {
    var uid = Auth.auth().currentUser?.uid
    
    public static func Instance() -> AuthService {
        return instance
    }
    
    private static let instance : AuthService = AuthService()
    
    
    private init() {
    }
    //MARK: Shared Instance

    func login(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if((error) != nil){
                print(error.debugDescription)
                store.dispatch(UserAction.authFai(error: error.debugDescription))
            }else{
                service.ACTIVITYLOG_SERVICE.create(id: user!.uid, activity: "Se inicio sesión", photo: "", type: "sesion")
            }
        }
    }
    func login(credential:AuthCredential){
        Auth.auth().signIn(with: credential ) { (user, error) in
            service.ACTIVITYLOG_SERVICE.create(id: user!.uid, activity: "Se inicio sesión", photo: "", type: "sesion")
        }
    }
    func userStatus(state: String) -> Void {
        Constants.FirDatabase.REF_USERS.child(self.uid!).updateChildValues(["online": state])
    }
    func logOut(){
        if let uid = Auth.auth().currentUser?.uid {
            service.NOTIFICATION_SERVICE.deleteToken(token: service.NOTIFICATION_SERVICE.token, id: uid)
            self.userStatus(state: "Offline")
        }
        store.state = nil
        try! Auth.auth().signOut()
    }

    //Create account with federate entiies like Facebook Twitter Google  etc
    func createAccount(user: AnyObject)   {
        let imageName = NSUUID().uuidString
        let url = user.photoURL
        let data = NSData(contentsOf:url!! as URL)
        if let uploadData = UIImagePNGRepresentation(UIImage(data: data! as Data)!){
            Constants.FirStorage.STORAGEREF.child("users").child(user.uid).child("images").child("\(imageName).jpg").putData(uploadData, metadata: nil) { metadata, error in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                    print(error.debugDescription)
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    if let downloadURL = metadata?.downloadURL()?.absoluteString {
                        let xuserModel = ["name" : user.displayName!,
                                          "photoUrl": downloadURL] as [String : Any]
                        Constants.FirDatabase.REF_USERS.child(user.uid).setValue(xuserModel)
                        service.ACTIVITYLOG_SERVICE.create(id: user.uid, activity: "Se creo la cuenta", photo: downloadURL, type: "sesion")
                        store.dispatch(UserAction.getbyId(uid: user.uid))
                    }
                }
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
    func isAuth()  {
        var view = false
        Auth.auth().addStateDidChangeListener { auth, user in
            
            if (user != nil) {
                self.checkUserAgainstDatabase(completion: {(success, error ) in
                    if success {
                        if !view {
                            store.dispatch(UserAction.getbyId(uid: (user?.uid)!))
                            view = !view
                        }
                    }else{
                       self.logOut()
                    }
                })
            }else{
                self.logOut()
            }
        }
    }


}
