//
//  RequestService.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 07/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Toast_Swift
import Firebase
protocol RequestService {
    
    var handles: [(String,UInt,FIRDataEventType)] {get set}
    func addHandle(_ handle: UInt, ref: String, action: FIRDataEventType) -> Void
    func removeHandles() -> Void
    func notExistSnapshot() -> Void
    func inserted(ref: FIRDatabaseReference) -> Void
    func routing(snapshot: FIRDataSnapshot, action: FIRDataEventType, ref: String) -> Void
    func delete(_ ref: String, callback: @escaping ((_ results: Any) -> Void))
    
}
extension RequestService {
    func insert(_ ref: String, value: Any, callback: @escaping ((Any) -> Void)) {
        Constants.FirDatabase.REF.child(ref).setValue(value as! NSDictionary, withCompletionBlock: {(error, ref) in
            if error != nil {
                print(error.debugDescription)
            }else {
                DispatchQueue.main.async {
                    self.inserted(ref: ref)
                    callback(ref as FIRDatabaseReference)
                }
            }
        })
    }
    func delete(_ ref: String, callback: @escaping ((Any) -> Void)) {
        Constants.FirDatabase.REF.child(ref).removeValue(completionBlock: { error, ref in
            if error != nil {
                print(error.debugDescription)
            }
        })
    }
    func update(_ ref: String, value: [AnyHashable : Any], callback: @escaping ((Any) -> Void)) {
        Constants.FirDatabase.REF.child(ref).updateChildValues(value, withCompletionBlock: {(error, ref) in
            if error != nil {
                print(error.debugDescription)
            }else {
                DispatchQueue.main.async {
                    callback(ref as FIRDatabaseReference)
                }
            }
        })
    }
    
    func child_action(ref: String, action: FIRDataEventType) -> Void {
        let handle = Constants.FirDatabase.REF.child(ref).observe(action, with: {(snapshot) in
            if(snapshot.exists()){
                self.routing(snapshot: snapshot, action: action, ref: ref)
            }else{
                self.notExistSnapshot()
            }
        }, withCancel: {(error) in
            print(error.localizedDescription)
        })
        self.addHandle(handle, ref: ref, action: action)
    }

    func valueSingleton(ref: String) -> Void {
        Constants.FirDatabase.REF.child(ref).observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists(){
                self.routing(snapshot: snapshot, action: .value, ref: ref)
            }else{
                self.notExistSnapshot()
            }
        }, withCancel: {(error) in
            print(error.localizedDescription)
        })
    }


}
