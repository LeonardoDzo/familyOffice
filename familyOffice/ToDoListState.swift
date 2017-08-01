//
//  ToDoListState.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct ToDoListState: StateType{
    var items: [String:[ToDoList.ToDoItem]] = [:]
    var status : Result<Any> = .none
}
