//
//  EventSvc.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 11/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase
import RealmSwift
import ReSwift

enum EventAction : description {
    case get(byId: String),
         save(event : EventEntity),
         update(event: EventEntity),
         delete(eid: EventEntity),
         none
    
    init(){
        self = .none
    }
    
}

class EventSvc : Action, EventProtocol {
    var handles: [(String,UInt,DataEventType)] = []
    var status: Result<Any> = .loading
    
    var fromView: RoutingDestination!
    
    var id: String!
    
    typealias EnumType = EventAction
    var action = EventAction()
    
    convenience init(_ action: EventAction) {
        self.init()
        self.id = UUID().uuidString
        self.action = action
        status = .Loading(action)
        self.fromView = RoutingDestination(rawValue: UIApplication.topViewController()?.restorationIdentifier ?? "" )
    }
    
}
extension EventSvc : RequestProtocol {
  
    
    func added(snapshot: DataSnapshot) {
        do {
            if let snapshotValue = snapshot.value as? NSDictionary {
                if let data = snapshotValue.jsonToData() {
                    let event = try JSONDecoder().decode(EventEntity.self, from: data)
                    let ref = ref_events(event.id)
                    sharedMains.initObserves(ref:ref, actions: [.childChanged])
                    self.status = .Finished(action)
                    rManager.save(objs: event)
                    if event.repeatmodel != nil {
                        event.update(date: event.startdate, repeatM: event.repeatmodel!)
                    }
                    store.dispatch(self)
                }
            }
        }catch let error {
            print(error)
            self.status = .Failed(error)
            store.dispatch(self)
        }
    }
    
    func updated(snapshot: DataSnapshot, id: Any) {
    }
    
    func removed(snapshot: DataSnapshot) {
    }
    
    fileprivate func removeEventsLocal(_ ref: String) {
        if let id = ref.components(separatedBy: "/").last {
            if let event = rManager.realm.object(ofType: EventEntity.self, forPrimaryKey: id) {
                try! rManager.realm.write {
                    rManager.realm.delete(event.myEvents)
                    rManager.realm.delete(event)
                }
            }
            
        }
    }
    
    func notExistSnapshot(ref: String) {
        removeEventsLocal(ref)
    }
    
    func create(event: EventEntity)  -> Void {
        let newevent = event
        if let id = getUser()?.id {
            newevent.admins.append(RealmString(value: id))
        }
        newevent.id = Constants.FirDatabase.REF.childByAutoId().key
        let reference = "events/\(event.id!)"
        if let json = event.todictionary() {
            self.insert(reference, value: json, callback: { (ref) in
                if ref is DatabaseReference {
                    self.status = .Finished(self.action)
//                    rManager.save(objs: newevent)
//                    if newevent.repeatmodel != nil {
//                        newevent.update(date: newevent.startdate, repeatM: newevent.repeatmodel!)
//                    }
                     store.dispatch(self)
                }
            })
        }
    }
    
    func update(_ event:EventEntity) {
        let reference = ref_events(event.id)
        if let json = event.todictionary() {
            self.update(reference, value: json) { (res) in
                if res is DatabaseReference {
                    self.status = .Finished(self.action)
                }else{
                    self.status = .Failed(self.action)
                }
                store.dispatch(self)
            }
        }
        
       
    }
}
extension EventSvc: Reducer {
    typealias StoreSubscriberStateType = EventState
    
    func handleAction(state: EventState?) -> EventState {
        var state = state ?? EventState(status: .none)
        state.status = self.status
        switch self.status{
        case .loading, .Loading(_):
            switch self.action {
                case .save(let event):
                    self.create(event: event)
                break
                case .update(let event):
                    self.update(event)
                break
                case .get(let Id):
                    self.valueSingleton(ref: "events/\(Id)")
                break
                default:
                    break
            }
            break
        default:
            break
        }
        return state
    }
}
