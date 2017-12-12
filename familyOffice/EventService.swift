//
//  Event.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 24/04/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase

class EventService {
    public var events: [EventEntity]
    var handles: [(String,UInt,DataEventType)] = []
    private init(events: [EventEntity]){
        self.events = events
    }
    
    public static func Instance() -> EventService {
        return instance
    }
    func test() -> Void {
        
    }
    private static let instance : EventService = EventService(events: [])
    
    func addEventlocal(snapshot: DataSnapshot) -> Void {
       
    }
    func addEventToMember(uid: String, eid: String)-> Void {
        Constants.FirDatabase.REF_USERS.child("\(uid)/events").updateChildValues([eid:true])
    }
    
}

extension EventService : RequestService  {
    func inserted(ref: DatabaseReference) {
    }

    func notExistSnapshot() {
    }

    func addHandle(_ handle: UInt, ref: String, action: DataEventType) {
    }
    
    func removeHandles() {
    }

    func routing(snapshot: DataSnapshot, action: DataEventType, ref: String) {
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
