//
//  AppState.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct AppState: StateType{
    var routingState: RoutingState
    var UserState: UserState
    var GoalsState : GoalState
    var FamilyState: FamilyState
    
    var GalleryState: GalleryState
    var ToDoListState: ToDoListState
    var ContactState: ContactState
    var MedicineState: MedicineState
    var IllnessState: IllnessState
    var FaqState: FaqState
    var safeBoxState: SafeBoxState

    
    var notifications = [NotificationModel]()
}
enum Result<T> {
    case loading
    case failed
    case Failed(T)
    case finished
    case Finished(T)
    case noFamilies
    case none
}
