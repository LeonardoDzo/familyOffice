//
//  ToDoListService.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ToDoListService: RequestService{
    func notExistSnapshot() {
        
    }

    var items: [ToDoList.ToDoItem] = []
    var handles: [(String, UInt, FIRDataEventType)] = []
    let basePath = "todolist/\((store.state.UserState.user?.id)!)"
    
    private init(){}
    
    static private let instance = ToDoListService()
    
    public static func Instance() -> ToDoListService { return instance}
    
    func routing(snapshot: FIRDataSnapshot, action: FIRDataEventType, ref: String){
        switch action {
        case .childAdded:
            self.added(snapshot:snapshot)
            break
        case .childRemoved:
            self.removed(snapshot:snapshot)
            break
        case .childChanged:
            self.updated(snapshot:snapshot, id: snapshot.key)
            break
        case .value:
            break
        default:
            break
        }
    }
    
    func initObserves(ref: String, actions: [FIRDataEventType]) -> Void {
        for action in actions{
            if !handles.contains(where: {$0.0 == ref && $0.2 == action}){
                self.child_action(ref: ref, action: action)
            }
        }
    }
    
    func addHandle(_ handle: UInt, ref: String, action: FIRDataEventType) {
        self.handles.append(ref, handle, action)
    }
    
    func removeHandles() {
        for handle in self.handles {
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    
    func inserted(ref: FIRDatabaseReference) {
        Constants.FirDatabase.REF_USERS.child((store.state.UserState.user?.id!)!).child("todolist").updateChildValues([ref.key:true])
        
        store.state.ToDoListState.status = .finished
    }
    
}

extension ToDoListService: repository{
    func added(snapshot: FirebaseDatabase.FIRDataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let item = ToDoList.ToDoItem(snapshot: snapshot)
        
        if (store.state.ToDoListState.items[id] == nil) {
            store.state.ToDoListState.items[id] = []
        }
        
        if !(store.state.ToDoListState.items[id]?.contains(where: {$0.id == item.id}))!{
            store.state.ToDoListState.items[id]?.append(item)
        }
    }
    
    func updated(snapshot: FirebaseDatabase.FIRDataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let item = ToDoList.ToDoItem(snapshot: snapshot)
        if let index = store.state.ToDoListState.items[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.ToDoListState.items[id]?[index] = item
        }
    }
    
    func removed(snapshot: FirebaseDatabase.FIRDataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        if let index = store.state.ToDoListState.items[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.ToDoListState.items[id]?.remove(at: index)
        }
    }
}
