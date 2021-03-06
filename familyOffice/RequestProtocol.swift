//
//  RequestProtocol.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

protocol RequestProtocol: repository {
    var handles: [(String,UInt,DataEventType)] {get set}
}
extension RequestProtocol {
    
    func insert(_ ref: String, value: Any, callback: @escaping ((Any) -> Void)) {
        Constants.FirDatabase.REF.child(ref).setValue(value as! NSDictionary, withCompletionBlock: {(error, ref) in
            if error != nil {
                print(error.debugDescription)
            }else {
                DispatchQueue.main.async {
                    callback(ref as DatabaseReference)
                }
            }
        })
    }
    func delete(_ ref: String, callback: @escaping ((Bool) -> Void)) {
        Constants.FirDatabase.REF.child(ref).removeValue(completionBlock: { error, ref in
            if error != nil {
                print(error.debugDescription)
                callback(false)
            }else{
                callback(true)
            }
        })
    }
    func update(_ ref: String, value: [AnyHashable : Any], callback: @escaping ((Any) -> Void)) {
        Constants.FirDatabase.REF.child(ref).updateChildValues(value, withCompletionBlock: {(error, ref) in
            if error != nil {
                callback(false)
            }else {
                callback(ref as DatabaseReference)
            }
        })
    }

    func child_action(ref: String, action: DataEventType, _ toMe: Bool? = false) -> Void {
        let xref = Constants.FirDatabase.REF.child(ref)
        print(xref.ref)
        let handle : UInt!
    
        if toMe!, let id = getUser()?.id {
          handle  = xref.queryOrdered(byChild: "boss").queryEqual(toValue: id).observe(action, with: {(snapshot) in
                if(snapshot.exists()){
                    self.routing(snapshot: snapshot, action: action, ref: ref)
                }else{
                    self.notExistSnapshot(ref: ref)
                }
            }, withCancel: {(error) in
                print(error.localizedDescription)
            })
            
        }else{
           handle = xref.observe(action, with: {(snapshot) in
                if(snapshot.exists()){
                    self.routing(snapshot: snapshot, action: action, ref: ref)
                }else{
                    self.notExistSnapshot(ref: ref)
                }
            }, withCancel: {(error) in
                print(error.localizedDescription)
            })
        }
        self.handles.append((ref,handle,action))
    }
    
    func valueSingleton(ref: String) -> Void {
        Constants.FirDatabase.REF.child(ref).observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists(){
                self.routing(snapshot: snapshot, action: .value, ref: ref)
            }else{
                self.notExistSnapshot(ref: ref)
            }
        }, withCancel: {(error) in
            print(error.localizedDescription)
        })
    }
    
    func routing(snapshot: DataSnapshot, action: DataEventType, ref: String) {
        switch action {
        case .childAdded:
            self.added(snapshot: snapshot)
            break
        case .childRemoved:
            self.removed(snapshot: snapshot)
            break
        case .childChanged:
            self.updated(snapshot: snapshot, id: snapshot.key)
            break
        case .value:
            self.added(snapshot: snapshot)
            break
        default:
            break
        }
    }
    func removeHandles() {
        for handle in self.handles {
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    func removeHandles(ref: String) {
        let handlesFiltered =  self.handles.filter { (key,_,_) -> Bool in
            return key == ref
        }
        handlesFiltered.enumerated().forEach { (index, handle) in
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
            self.handles.remove(at: index)
        }
    }
}
