//
//  FamilyS.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import RealmSwift
import Firebase


enum PendingAction : description{
    case insert(pending: PendingEntity),
    update(pending: PendingEntity),
    delete(ref: String),
    getbyId(ref: String),
    none
    init(){
        self =  .none
    }
    
}

class PendingSvc: Action, EventProtocol {
    var handles = [(String, UInt, DataEventType)]()
    typealias EnumType = PendingAction
    var action: PendingAction = .none
    
    var status: Result<Any> = .none
    var id: String!
    var fromView: RoutingDestination!
    
    init() {
        self.status = .none
    }
    
    convenience init(_ action: PendingAction) {
        self.init()
        self.id = UUID().uuidString
        self.action = action
        status = .loading
        self.fromView = RoutingDestination(rawValue: UIApplication.topViewController()?.restorationIdentifier ?? "" )
    }
    func getDescription() -> String {
        return "\(self.action.description) \(self.status.description)"
    }
    
    func delete(_ ref: String) {
        self.delete(ref, callback: { deleted in
            if deleted {
                self.status = .Finished(self.action)
            }else{
                self.status = .Failed(self.action)
                
            }
            store.dispatch(self)
        })
    }
    
    func create(pending: PendingEntity) -> Void {
        let ref = ref_pending(pending)
        if let json = pending.toJSON() {
            self.insert(ref, value: json, callback: { (response) in
                if response is DatabaseReference {
                    self.status = .Finished(self.action)
                }else{
                    self.status = .failed
                }
                store.dispatch(self)
            })
        }
    }
    func update(pending: PendingEntity) -> Void {
        let ref = ref_pending(pending)
        if let json = pending.toJSON() {
            self.update(ref, value: json, callback: { ref in
                if ref is DatabaseReference {
                    self.status = .Finished(self.action)
                   
                }else{
                    self.status = .Failed(self.action)
                }
                 store.dispatch(self)
            })
        }else{
            self.status = .Failed(self.action)
            store.dispatch(self)
        }
        
    }
    
    func error() -> Void {
        self.status = .Failed(self.action)
        store.dispatch(self)
    }
    deinit {
        self.removeHandles()
    }
}
extension PendingSvc : RequestProtocol, RequestStorageSvc {
    
    func inserted(metadata: StorageMetadata, data: Data) {
        
    }
    
    func notExistSnapshot(ref: String) {
        if let id = ref.components(separatedBy: "/").last {
            if let family = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: id) {
                rManager.deteObject(objs: family)
            }
        }
    }
    
    
    func added(snapshot: DataSnapshot) {
        do {
            if let dictionary = snapshot.value as? NSDictionary {
                if let data = dictionary.jsonToData() {
                    let pending =  try JSONDecoder().decode(PendingEntity.self, from: data)
                    rManager.save(objs: pending)
                    self.status = .finished
                    store.dispatch(self)
                }else{
                    self.status = .Failed("Error al parsear datos")
                    store.dispatch(self)
                }
            }
            else{
                self.status = .Failed("Error al parsear datos")
                store.dispatch(self)
            }
        }catch let error {
            print(error)
            self.status = .Failed(error.localizedDescription)
            store.dispatch(self)
        }
        
        
    }
    func removed(snapshot: DataSnapshot) {

    }
    
    func updated(snapshot: DataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        if let index = store.state.FamilyState.families.indexOf(fid: id){
            store.state.FamilyState.families.items[index].update(snapshot: snapshot)
        }
    }
    
    
}

extension PendingSvc : Reducer {
    typealias StoreSubscriberStateType = PendingState
    func handleAction(state: PendingState?) -> PendingState {
        var state = state ?? PendingState(state: .none)
        state.state = self.status
        switch self.status {
        case .loading,  .Loading(_):
            switch self.action {
            case .insert(let pending):
                self.create(pending: pending)
                break
            case .update(let pending):
                self.update(pending: pending)
                break
            case .delete(let ref):
                self.delete(ref)
                break
            case .getbyId(let ref):
               
                self.valueSingleton(ref: ref )
                
                
                break
            case .none:
                break
            }
            break
        case .failed, .Failed(_):
            break
        case .finished:
            break
        case .Finished(_):
            break
        case .none, .noFamilies:
            break
        }
        return state
    }
}

