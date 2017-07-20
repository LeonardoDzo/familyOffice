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
    var uid = FIRAuth.auth()?.currentUser?.uid
    
    public static func Instance() -> AuthService {
        return instance
    }
    
    private static let instance : AuthService = AuthService()
    
    
    private init() {
    }
    //MARK: Shared Instance

    func login(email: String, password: String){
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            if((error) != nil){
                print(error.debugDescription)
                store.state.UserState.status = .failed
            }else{
                service.ACTIVITYLOG_SERVICE.create(id: user!.uid, activity: "Se inicio sesión", photo: "", type: "sesion")
            }
        }
    }
    func login(credential:FIRAuthCredential){
        FIRAuth.auth()?.signIn(with: credential ) { (user, error) in
            service.ACTIVITYLOG_SERVICE.create(id: user!.uid, activity: "Se inicio sesión", photo: "", type: "sesion")
        }
    }
    func userStatus(state: String) -> Void {
        Constants.FirDatabase.REF_USERS.child(self.uid!).updateChildValues(["online": state])
    }
    func logOut(){
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            service.NOTIFICATION_SERVICE.deleteToken(token: service.NOTIFICATION_SERVICE.token, id: uid)
            self.userStatus(state: "Offline")
        }
        store.state.ContactState.contacts.removeAll()
        store.state.UserState.users.removeAll()
        store.state.UserState.user = nil
        store.state.FamilyState.families.items.removeAll()
        store.state.GalleryState.Gallery.removeAll()
        store.state.ToDoListState.items.removeAll()
        store.state.UserState.status = .none
        try! FIRAuth.auth()!.signOut()
    }

    //Create account with federate entiies like Facebook Twitter Google  etc
    func createAccount(user: AnyObject)   {
        let imageName = NSUUID().uuidString
        let url = user.photoURL
        let data = NSData(contentsOf:url!! as URL)
        if let uploadData = UIImagePNGRepresentation(UIImage(data: data! as Data)!){
            Constants.FirStorage.STORAGEREF.child("users").child(user.uid).child("images").child("\(imageName).jpg").put(uploadData, metadata: nil) { metadata, error in
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
                        //self.userStatus(state: "Online")
                    }
                }
            }
        }
    }
    func checkUserAgainstDatabase(completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        guard let currentUser = FIRAuth.auth()?.currentUser else { return }
        currentUser.getTokenForcingRefresh(true) { (idToken, error) in
            if let error = error {
                completion(false, error as NSError?)
                print(error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
    func isAuth()  {
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if (user != nil) {
                self.checkUserAgainstDatabase(completion: {(success, error ) in
                    if success {
                        store.dispatch(GetUserAction(uid: (user?.uid)!))
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
