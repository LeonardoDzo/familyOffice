//
//  ToDoListActions.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift


struct InsertToDoListItemAction: Action{
    var item: ToDoList.ToDoItem!
    init(item: ToDoList.ToDoItem){
        self.item = item
    }
}

struct UpdateToDoListItemAction: Action{
    var item: ToDoList.ToDoItem!
    init(item: ToDoList.ToDoItem){
        self.item = item
    }

}

struct DeleteToDoListItemAction: Action{
    static let type = "TODOLIST_ACTION_DELETE"
    var item: ToDoList.ToDoItem!
    init(item: ToDoList.ToDoItem){
        self.item = item
    }
}

