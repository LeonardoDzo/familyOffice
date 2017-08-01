//
//  NotificationService.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 13/02/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Alamofire
import Firebase

class NotificationService {
    var token = ""
    var handles: [(String, UInt, FIRDataEventType)]  = []
    public var notifications : [NotificationModel] = []
    public var sections : [SectionNotification] = []
    private init(){
    }
    public static func Instance() -> NotificationService {
        return instance
    }
    
    private static let instance : NotificationService = NotificationService()
    
    func saveToken() -> Void {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            service.NOTIFICATION_SERVICE.token = refreshedToken
        }
        if store.state.UserState.user != nil {
            Constants.FirDatabase.REF_USERS.child("\((store.state.UserState.user?.id)!)/\(User.kUserTokensFCMeKey)").updateChildValues([self.token: true])
        }
    }
    func send(title: String, message: String, to: String) -> Void {
        if let user = service.USER_SERVICE.users.first(where: {$0.id == to}) {
            for token in (user.tokens?.allKeys)! {
                sendNotification(title: title, message: message, to: token as! String)
            }
        }
    }
    func sendNotification(title: String, message: String, to: String){
        let headers = [
            "Content-Type" : "application/json",
            "Authorization": "key=\(Constants.ServerApi.SERVERKEY)"
        ]
        let _notification: Parameters? =
            [
                "to": "\(to)",
                "notification": [
                    "body": message,
                    "title": title
                ]
        ]
        
        Alamofire.request(Constants.ServerApi.NOTIFICATION_URL, method: .post, parameters: _notification, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {
            (res) in
            print(res)
        })
    }
    func seenNotification(index: Int) -> Void {
        self.notifications[index].seen = true
        Constants.FirDatabase.REF_NOTIFICATION.child(service.USER_SERVICE.users[0].id).child(self.notifications[index].id!).updateChildValues(self.notifications[index].toDictionary() as! [AnyHashable : Any])
    }
    
    func deleteToken(token: String, id: String) -> Void {
        Constants.FirDatabase.REF_USERS.child("\(id)/\(User.kUserTokensFCMeKey)/\(token)").removeValue()
    }
    
    func initObserves(ref: String, actions: [FIRDataEventType]) -> Void {
        for action in actions {
            if !handles.contains(where: { $0.0 == ref && $0.2 == action} ){
                self.child_action(ref: ref, action: action)
            }
        }
    }
    
}
extension NotificationService: RequestService {
    func addHandle(_ handle: UInt, ref: String, action: FIRDataEventType) {
        self.handles.append(ref,handle, action)
    }

    func routing(snapshot: FIRDataSnapshot, action: FIRDataEventType, ref: String) {
        if action == .childAdded {
            let not = NotificationModel(snapshot: snapshot)
            if !store.state.notifications.contains(not) {
                store.state.notifications.append(not)
            }
        }
    }
    
    func removeHandles() {
        for handle in self.handles {
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    func notExistSnapshot() {
        
    }
    func inserted(ref: FIRDatabaseReference) {
    }
}
