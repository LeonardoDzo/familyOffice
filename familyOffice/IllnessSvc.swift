//
//  IllnessSvc.swift
//  familyOffice
//
//  Created by Nan Montaño on 30/nov/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Firebase

class IllnessSvc : Action, EventProtocol {
    
    typealias EnumType = IllnessAction
    var id: String! = UUID().uuidString
    var handles: [(String, UInt, DataEventType)] = []
    var action = IllnessAction()
    var status: Result<Any> = Result.loading
    var fromView: RoutingDestination! = .none
    
    convenience init(_ action: IllnessAction) {
        self.init()
        self.action = action
        self.fromView = RoutingDestination(rawValue: UIApplication.topViewController()?.restorationIdentifier ?? "")
    }
    
    func getByUser(userId: String) {
        Constants.FirDatabase.REF.child("illness")
            .queryOrdered(byChild: "user")
            .queryEqual(toValue: userId)
            .observeSingleEvent(of: .childAdded, with: {snapshot in
                do {
                    guard snapshot.exists() else { return; }
                    guard let data = (snapshot.value as? NSDictionary)?.jsonToData() else {
                        return
                    }
                    let illness = try JSONDecoder().decode([IllnessEntity].self, from: data)
                    rManager.saveObjects(objs: illness)
                    self.status = .Finished(illness)
                    store.dispatch(self)
                } catch let err {
                    print(err)
                }
            })
    }
    
    func update(illness: IllnessEntity) {
        self.update("illness/\(illness.id)", value: illness.toJSON()!) { ref in
            self.status = ref is DatabaseReference
                ? .Finished(self.action)
                : .Failed(self.action)
            store.dispatch(self)
        }
    }
    
    func create(illness: IllnessEntity) {
        self.insert("illness\(illness.id)", value: illness) { ref in
            self.status = ref is DatabaseReference
                ? .Finished(self.action)
                : .Failed(self.action)
            store.dispatch(self)
        }
    }
    
    func getDescription() -> String {
        return "\(self.action.description) \(self.status.description)"
    }
}

extension IllnessSvc : RequestProtocol {
    func updated(snapshot: DataSnapshot, id: Any) {
        
    }
    
    func removed(snapshot: DataSnapshot) {
        
    }
    
    func notExistSnapshot() {
        
    }
    
    func added(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? NSDictionary else {
            return;
        }
        guard let data = value.jsonToData() else {
            return;
        }
        do {
        let illness = try JSONDecoder().decode(IllnessEntity.self, from: data)
        rManager.save(objs: illness)
        } catch let err {
            print(err)
        }
    }
}

extension IllnessSvc : Reducer {
    typealias StoreSubscriberStateType = IllnessState
    func handleAction(state: IllnessState?) -> IllnessState {
        var state = state ?? IllnessState(illnesses: [:], status: .none, requests: [:])
        state.status = self.status
        switch(status) {
        case .loading:
            switch self.action {
            case .getById(let uuid):
                self.valueSingleton(ref: "illness/\(uuid)")
                break
            case .getByUser(let user):
                self.getByUser(userId: user)
                break
            case .update(let entity):
                self.update(illness: entity)
                break
            case .create(let entity):
                break
            case .none:
                break
            default: break
            }
            break
        case .failed:
            break
        case .Failed(_):
            break
        case .finished:
            break
        case .Finished(_):
            break
        case .noFamilies:
            break
        case .none:
            break
        }
        return state
    }
}
