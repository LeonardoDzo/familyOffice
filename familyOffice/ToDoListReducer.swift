//
//  ToDoListReducer.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
import Firebase

struct ToDoListReducer: Reducer{
    
    func handleAction(action: Action, state: ToDoListState?) -> ToDoListState {
        var state = state ?? ToDoListState(items: [:], status: .none)
        switch action{
        case let action as InsertToDoListItemAction:
            if action.item == nil{
                return state
            }
            insertItem(action.item)
            state.status = .loading
            return state
        case let action as UpdateToDoListItemAction:
            if action.item == nil{
                return state
            }
            updateItem(action.item)
            state.status = .loading
            return state
        case let action as DeleteToDoListItemAction:
            if action.item == nil{
                return state
            }
            deleteItem(action.item)
            state.status = .loading
            return state
        default:break
        }
        return state
    }
    
    func insertItem(_ item: ToDoList.ToDoItem) -> Void {
        //seleccionar ruta por un ToDoList familiar??
        let id = store.state.UserState.user?.id!
        let path = "todolist/\(id!)/\(item.id!)"
        service.TODO_SERVICE.insert(path, value: item.toDictionary(), callback: {ref in
            if ref is FIRDatabaseReference{
                store.state.ToDoListState.items[id!]?.append(item)
                store.state.ToDoListState.status = .finished
            }
        })
    }
    
    func updateItem(_ item: ToDoList.ToDoItem) -> Void {
        let id = store.state.UserState.user?.id!
        let path = "todolist/\(id!)/\(item.id!)"
        service.TODO_SERVICE.update(path, value: item.toDictionary() as! [AnyHashable : Any], callback: { ref in
            if ref is FIRDatabaseReference {
                if let index = store.state.ToDoListState.items[id!]?.index(where: {$0.id! == item.id! }){
                    store.state.ToDoListState.items[id!]?[index] = item
                    store.state.ToDoListState.status = .finished
                }
                
            }
            
        })
    }
    
    func deleteItem(_ item: ToDoList.ToDoItem) -> Void {
        let id = store.state.UserState.user?.id!
        let path = "todolist/\(id!)/\(item.id!)"
        service.TODO_SERVICE.delete(path) { (Any) in
            if let index = store.state.ToDoListState.items[id!]?.index(where: {$0.id! == item.id! }){
                store.state.ToDoListState.items[id!]?.remove(at: index)
                store.state.ToDoListState.status = .finished
            }
        }
    }
}


