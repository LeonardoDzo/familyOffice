//
//  SafeBoxService.swift
//  familyOffice
//
//  Created by Developer on 8/16/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

class SafeBoxService: RequestService{
    func notExistSnapshot() {
        
    }
    
    var files: [SafeBoxFile] = []
    var handles: [(String,UInt,DataEventType)] = []

    private init() {}
    
    static private let instance = SafeBoxService()
    
    public static func Instance() -> SafeBoxService { return instance}
    
    func routing(snapshot: DataSnapshot, action: DataEventType, ref: String) {
        switch action{
        case .childAdded:
            self.added(snapshot:snapshot)
            break
        case .childChanged:
            self.updated(snapshot:snapshot, id: snapshot.key)
            break
        case .childRemoved:
            self.removed(snapshot:snapshot)
            break
        case .value:
            break
        default:
            break
        }
    }
    func initObservers(ref: String, actions: [DataEventType]) -> Void{
        for action in actions {
            if !handles.contains(where: {$0.0 == ref && $0.2 == action}){
                self.child_action(ref: ref, action: action)
            }
        }
    }
    
    func addHandle(_ handle: UInt, ref: String, action: DataEventType) {

        self.handles.append((ref, handle, action))
    }
    
    func removeHandles() {
        for handle in self.handles{
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    
    func inserted(ref: DatabaseReference) {
        store.state.safeBoxState.status = .none
    }
}

extension SafeBoxService: repository {
    func added(snapshot: DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let safeBoxFile = SafeBoxFile(snapshot: snapshot)
        
        if store.state.safeBoxState.safeBoxFiles[id] == nil {
            store.state.safeBoxState.safeBoxFiles[id] = []
        }
        
        if !(store.state.safeBoxState.safeBoxFiles[id]?.contains(where: {$0.id == safeBoxFile.id}))!{
            store.state.safeBoxState.safeBoxFiles[id]?.append(safeBoxFile)
        }
    }
    
    func updated(snapshot: DataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let safeBoxFile = SafeBoxFile(snapshot: snapshot)
        if let index = store.state.safeBoxState.safeBoxFiles[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.safeBoxState.safeBoxFiles[id]?[index] = safeBoxFile
        }
    }
    
    func removed(snapshot: DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        if let index = store.state.safeBoxState.safeBoxFiles[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.safeBoxState.safeBoxFiles[id]?.remove(at: index)
        }
    }
    
}

