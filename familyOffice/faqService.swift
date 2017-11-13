//
//  faqService.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/25/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FaqService: RequestService {
    func notExistSnapshot() {
        
    }
    
    var questions: [Question] = []
    var handles: [(String,UInt,DataEventType)] = []
    private init() {}
    
    static private let instance = FaqService()
    
    public static func Instance() -> FaqService { return instance}
    
    func routing(snapshot: DataSnapshot, action: DataEventType, ref: String) {
        switch action{
        case .childAdded:
            self.added(snapshot:snapshot)
            break
        case .childChanged:
            self.updated(snapshot:snapshot, id: snapshot.key)
            break
        case .childRemoved:
            self.removed(snapshot:snapshot)
            break
        case .value:
            break
        default:
            break
        }
    }
    
    func initObservers(ref: String, actions: [DataEventType]) -> Void{
        for action in actions {
            if !handles.contains(where: {$0.0 == ref && $0.2 == action}){
                self.child_action(ref: ref, action: action)
            }
        }
    }
    
    func addHandle(_ handle: UInt, ref: String, action: DataEventType) {
        self.handles.append((ref, handle, action))
    }
    
    func removeHandles() {
        for handle in self.handles{
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    
    func inserted(ref: DatabaseReference) {
        store.state.FaqState.status = .none
    }
    
//    func create(_ nQuestion: Question) -> Void {
//        let question = nQuestion
//        let id = store.state.UserState.user!.familyActive!
//        let path = "faq/\(id)/\(question.id!)"
//        
//        service.FAQ_SERVICE.insert(path, value: question.toDictionary()) { ref in
//            if ref is FIRDatabaseReference {
//                store.state.FaqState.questions[id]?.append(question)
//            }
//        }
//    }
}

extension FaqService: repository {
    func added(snapshot: DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let question = Question(snapshot: snapshot)
        
        if store.state.FaqState.questions[id] == nil {
            store.state.FaqState.questions[id] = []
        }
        
        if !(store.state.FaqState.questions[id]?.contains(where: {$0.id == question.id}))!{
            store.state.FaqState.questions[id]?.append(question)
        }
    }
    
    func updated(snapshot: DataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let question = Question(snapshot: snapshot)
        if let index = store.state.FaqState.questions[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.FaqState.questions[id]?[index] = question
        }
    }
    
    func removed(snapshot: DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        if let index = store.state.FaqState.questions[id]?.index(where: {$0.id == snapshot.key})  {
            store.state.FaqState.questions[id]?.remove(at: index)
        }
    }

}
