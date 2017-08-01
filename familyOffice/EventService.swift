//
//  Event.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 24/04/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
struct Events {
    var events: [Event]
}

class EventService {
    public var events: [Event]
    var handles: [(String,UInt,FIRDataEventType)] = []
    private init(events: [Event]){
        self.events = events
    }
    
    public static func Instance() -> EventService {
        return instance
    }
    func test() -> Void {
        
    }
    private static let instance : EventService = EventService(events: [])
    
    func addEventlocal(snapshot: FIRDataSnapshot) -> Void {
        let event = Event.init(snapshot: snapshot)
        
        if !events.contains(where: {$0.id == event.id}){
            events.append(event)
            NotificationCenter.default.post(name: notCenter.SUCCESS_NOTIFICATION, object: event.id)
        }
    }
    func addEventToMember(uid: String, eid: String)-> Void {
        Constants.FirDatabase.REF_USERS.child("\(uid)/events").updateChildValues([eid:true])
    }
    
}

extension EventService : RequestService  {
    func notExistSnapshot() {
        
    }

    func addHandle(_ handle: UInt, ref: String, action: FIRDataEventType) {
        
    }
    func removeHandles() {
    }

    func routing(snapshot: FIRDataSnapshot, action: FIRDataEventType, ref: String) {
    }


    func inserted(ref: FIRDatabaseReference){
        service.USER_SERVICE.users[0].events?.append(ref.key)
        self.addEventToMember(uid: service.USER_SERVICE.users[0].id, eid: ref.key)
    }
    
    func delete(_ ref: String, callback: @escaping ((Any) -> Void)) {
        
    }
    
    func update(_ ref: String, value: [AnyHashable : Any], callback: @escaping ((Any) -> Void)) {
        Constants.FirDatabase.REF.child(ref).updateChildValues(value, withCompletionBlock: {(error, ref) in
            if error != nil {
                print(error.debugDescription)
            }else {
                DispatchQueue.main.async {
                    callback(ref.key)
                }
            }
        })
    }
}
