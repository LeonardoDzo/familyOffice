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
        var userState: UserState!
        var famState: FamilyState!
        var authState: AuthState!
        var eventState: EventState!
        if let useraction =  action as? UserS {
            userState = useraction.handleAction(state: state?.UserState)
        }else{
            userState = state?.UserState != nil ? state?.UserState : UserState(users: .none, user: .none)
        }
        if let authAction = action as? AuthSvc{
            authState = authAction.handleAction(state: state?.authState)
        }else{
            authState = state?.authState != nil ? state?.authState : AuthState(state: .none)
        }

        if  let familyAction = action as? FamilyS {
            famState = familyAction.handleAction(state: state?.FamilyState)
        }else{
            famState = state?.FamilyState != nil ? state?.FamilyState : FamilyState(families: FamilyList(), status: .none)
        }
        
        
        if  let eventAction = action as? EventSvc {
            eventState = eventAction.handleAction(state: state?.EventState)
        }else{
            eventState = state?.EventState != nil ? state?.EventState : EventState(status: .none)
        }
        
       

        return AppState(
            routingState: routingReducer(action: action, state: state?.routingState),
            authState: authState,
            UserState:  userState,
            GoalsState: goalReducer.handleAction(action: action),
            FamilyState: famState,
            EventState: eventState,
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
    

