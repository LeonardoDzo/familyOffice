//
//  AppReducer.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
    
    func appReducer(action: Action, state: AppState?) -> AppState {
        var goalReducer = GoalReducer(state?.GoalsState)
        let useraction =  action as? UserS
        let authAction = action as? AuthSvc
        return AppState(
            routingState: routingReducer(action: action, state: state?.routingState),
            authState: authAction != nil ? (authAction?.handleAction(state: state?.authState))! : AuthState(state: .none),
            UserState:  useraction != nil ? (useraction?.handleAction(state: state?.UserState))! : UserState(users: .none, user: .none),
            GoalsState: goalReducer.handleAction(action: action),
            FamilyState: FamilyReducer().handleAction(action: action, state: state?.FamilyState),
            GalleryState: GalleryReducer().handleAction(action: action, state: state?.GalleryState),
            ToDoListState: ToDoListReducer().handleAction(action: action, state: state?.ToDoListState),
            ContactState: ContactReducer().handleAction(action: action, state: state?.ContactState),
            MedicineState: MedicineReducer().handleAction(action: action, state: state?.MedicineState),
            IllnessState: IllnessReducer().handleAction(action: action, state: state?.IllnessState),
            FaqState: FaqReducer().handleAction(action: action, state: state?.FaqState),
            safeBoxState: SafeBoxReducer().handleAction(action: action, state: state?.safeBoxState),
            notifications: state?.notifications ?? []
        )
    }
    

