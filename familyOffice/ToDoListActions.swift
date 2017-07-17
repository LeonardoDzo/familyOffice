//
//  ToDoListActions.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder

let todolistActionTypeMap: TypeMap = [
                                    InsertToDoListItemAction.type:InsertToDoListItemAction.self,
                                    UpdateToDoListItemAction.type:UpdateToDoListItemAction.self,
                                    DeleteToDoListItemAction.type:DeleteToDoListItemAction.self]

struct InsertToDoListItemAction: StandardActionConvertible{
    static let type = "TODOLIST_ACTION_INSERT"
    var item: ToDoList.ToDoItem!
    init(item: ToDoList.ToDoItem){
        self.item = item
    }
    init(_ standardAction: StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertToDoListItemAction.type, payload: [:], isTypedAction: true)
    }
}

struct UpdateToDoListItemAction: StandardActionConvertible{
    static let type = "TODOLIST_ACTION_UPDATE"
    var item: ToDoList.ToDoItem!
    init(item: ToDoList.ToDoItem){
        self.item = item
    }
    init (_ standarAction:StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: UpdateToDoListItemAction.type, payload: [:], isTypedAction: true)
    }
}

struct DeleteToDoListItemAction: StandardActionConvertible{
    static let type = "TODOLIST_ACTION_DELETE"
    var item: ToDoList.ToDoItem!
    init(item: ToDoList.ToDoItem){
        self.item = item
    }
    init (_ standarAction:StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: UpdateToDoListItemAction.type, payload: [:], isTypedAction: true)
    }
}

