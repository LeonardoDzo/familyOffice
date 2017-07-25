//
//  IllnessReducer.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/20/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
import Firebase

struct IllnessReducer: Reducer {
    func handleAction(action: Action, state: IllnessState?) -> IllnessState {
        var state = state ?? IllnessState(illnesses: [:], status: .none)
        switch action {
        case let action as InsertIllnessAction:
            if action.illness == nil{
                return state
            }
            insertIllness(action.illness)
            state.status = .loading
            return state
        case let action as UpdateIllnessAction:
            if action.illness == nil{
                return state
            }
            updateIllness(action.illness)
            state.status = .loading
            return state
        case let action as DeleteIllnessAction:
            if action.illness == nil{
                return state
            }
            deleteIllness(action.illness)
            state.status = .loading
            return state
        default:
            break
        }
        return state
    }
    
    func insertIllness(_ illness: Illness) -> Void {
        let id = service.USER_SERVICE.users[0].familyActive!
        let path = "illnesses/\(id)/\(illness.id!)"
        service.ILLNESS_SERVICE.insert(path, value: illness.toDictionary(), callback: {ref in
            if ref is FIRDatabaseReference {
                store.state.IllnessState.illnesses[id]?.append(illness)
                store.state.IllnessState.status = .finished
            }
        })
    }
    
    func updateIllness(_ illness: Illness) -> Void {
        let id = service.USER_SERVICE.users[0].familyActive!
        let path = "illnesses/\(id)/\(illness.id!)"
        service.ILLNESS_SERVICE.update(path, value: illness.toDictionary() as! [AnyHashable:Any]) { ref in
            if ref is FIRDatabaseReference {
                if let index = store.state.IllnessState.illnesses[id]?.index(where: {$0.id == illness.id}){
                    store.state.IllnessState.illnesses[id]?[index] = illness
                    store.state.IllnessState.status = .finished
                }
            }
        }
    }
    
    func deleteIllness(_ illness: Illness) -> Void {
        let id = service.USER_SERVICE.users[0].familyActive!
        let path = "illnesses/\(id)/\(illness.id!)"
        service.ILLNESS_SERVICE.delete(path) { (Any) in
            if let index = store.state.IllnessState.illnesses[id]?.index(where: {$0.id == illness.id}){
                store.state.IllnessState.illnesses[id]?.remove(at: index)
                store.state.IllnessState.status = .finished
            }
        }
    }
}
