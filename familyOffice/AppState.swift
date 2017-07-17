//
//  AppState.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
struct AppState: StateType{
    var GoalsState : GoalState
    var FamilyState: FamilyState
    var UserState: UserState
    var GalleryState: GalleryState
    var ToDoListState: ToDoListState
    var ContactState: ContactState

}
enum Result<T> {
    case loading
    case failed
    case Failed(T)
    case finished
    case Finished(T)
    case none
}
