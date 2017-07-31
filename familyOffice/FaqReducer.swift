//
//  FaqReducer.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/25/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
import Firebase

struct FaqReducer: Reducer {
    func handleAction(action: Action, state: FaqState?) -> FaqState {
        var state = state ?? FaqState(questions: [:], status: .none)
        switch action {
        case let action as InsertFaqAction:
            if action.question == nil{
                return state
            }
            insertQuestion(action.question)
            state.status = .loading
            return state
        case let action as UpdateFaqAction:
            if action.question == nil{
                return state
            }
            updateQuestion(action.question)
            state.status = .loading
            return state
        case let action as DeleteFaqAction:
            if action.question == nil{
                return state
            }
            deleteQuestion(action.question)
            state.status = .loading
            return state
        default:
            break
        }
        return state
    }
    
    func insertQuestion(_ question: Question) -> Void {
        let id = store.state.UserState.user?.familyActive!
        let path = "faq/\(id!)/\(question.id!)"
        service.FAQ_SERVICE.insert(path, value: question.toDictionary(), callback: {ref in
            if ref is FIRDatabaseReference {
                store.state.FaqState.status = .finished
            }
        })
    }
    
    func updateQuestion(_ question: Question) -> Void {
        let id = store.state.UserState.user?.familyActive!
        let path = "faq/\(id!)/\(question.id!)"
        service.FAQ_SERVICE.update(path, value: question.toDictionary() as! [AnyHashable:Any]) { ref in
            if ref is FIRDatabaseReference {
                if let index = store.state.FaqState.questions[id!]?.index(where: {$0.id! == question.id!}){
                    store.state.FaqState.questions[id!]?[index] = question
                    store.state.FaqState.status = .finished
                }
            }
        }
    }
    
    func deleteQuestion(_ question: Question) -> Void {
        let id = store.state.UserState.user?.familyActive!
        let path = "faq/\(id!)/\(question.id!)"
        service.FAQ_SERVICE.delete(path) { (Any) in
            if let index = store.state.FaqState.questions[id!]?.index(where: {$0.id! == question.id!}){
                store.state.FaqState.questions[id!]?.remove(at: index)
                store.state.FaqState.status = .finished
            }
        }
    }
}
