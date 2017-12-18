//
//  ContactService.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 11/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

class ContactService {
    var handles: [(String,UInt,DataEventType)] = []
    private init() {}
    let settingLauncher = SettingLauncher()
    static private let instance = ContactService()
    
    public static func Instance() -> ContactService { return instance }
    
    func routing(snapshot: DataSnapshot, action: DataEventType, ref: String) {
        switch action {
        case .childAdded:
            self.added(snapshot: snapshot)
            break
        case .childRemoved:
            self.removed(snapshot: snapshot)
            break
        case .childChanged:
            self.updated(snapshot: snapshot, id: snapshot.key)
            break
        case .value:
            //self.add(value: snapshot)
            break
        default:
            break
        }
    }
    
    func create(_ contact: Contact) -> Void {
        let contact = contact
        if let user = store.state.UserState.getUser(), let fid = user.familyActive {
            let path = "contacts/\(fid)/\(contact.id!)"
            self.insert(path, value: contact.toDictionary(), callback: {ref in
                if ref is DatabaseReference {
                    store.state.ContactState.contacts[fid]?.append(contact)
                    store.state.ContactState.status = .finished
                }
            })
        }
       
    }
    
    func update(_ contact: Contact) -> Void {
        if let user = store.state.UserState.getUser(), let fid = user.familyActive {
            let path = "contacts/\(fid)/\(contact.id!)"
            service.GOAL_SERVICE.update(path, value: contact.toDictionary() as! [AnyHashable : Any], callback: { ref in
                if ref is DatabaseReference {
                    if let index = store.state.ContactState.contacts[fid]?.index(where: {$0.id == contact.id }){
                        store.state.ContactState.contacts[fid]?[index] = contact
                        store.state.ContactState.status = .finished
                    }
                    
                }
                
            })
        }
    }
    
    func delete(_ ref: String, callback: @escaping ((Any) -> Void)) {
    }
    
    func getPath(type: Int) -> String {
        if type == 0 {
            return store.state.UserState.getUser()!.id!
        }else{
            return store.state.UserState.getUser()!.familyActive!
        }
    }
}
extension ContactService : RequestService {
    func notExistSnapshot() {
        
    }
    func initObserves(ref: String, actions: [DataEventType]) -> Void {
        for action in actions {
            if !handles.contains(where: { $0.0 == ref && $0.2 == action} ){
                self.child_action(ref: ref, action: action)
            }
        }
    }
    
    func addHandle(_ handle: UInt, ref: String, action: DataEventType) {
        self.handles.append((ref,handle, action))
    }
    
    func removeHandles() {
        for handle in self.handles {
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    
    func inserted(ref: DatabaseReference) {
        store.state.ContactState.status = .finished
        
    }
}
extension ContactService: repository {
    func notExistSnapshot(ref: String) {
        
    }
    
    func added(snapshot: DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let contact = Contact(snapshot: snapshot)
        
        if (store.state.ContactState.contacts[id] == nil) {
            store.state.ContactState.contacts[id] = []
        }
        
        if !(store.state.ContactState.contacts[id]?.contains(where: {$0.id == contact.id}))!{
            store.state.ContactState.contacts[id]?.append(contact)
        }
    }
    
    func updated(snapshot: DataSnapshot, id: Any) {
       /* let id = snapshot.ref.description().components(separatedBy: "/")[4]
        let goal = Goal(snapshot: snapshot)
        if let index = store.state.GoalsState.goals[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.GoalsState.goals[id]?[index] = goal
        } */
    }
    
    func removed(snapshot: DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        if let index = store.state.ContactState.contacts[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.GoalsState.goals[id]?.remove(at: index)
        }
    }
}
