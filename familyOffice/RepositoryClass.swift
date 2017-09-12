//
//  ListenersClass.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 07/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import FirebaseDatabase
import ReSwift
@objc protocol repository : class {
    
    func added(snapshot: DataSnapshot) -> Void
    func updated(snapshot: DataSnapshot, id: Any) -> Void
    func removed(snapshot: DataSnapshot) -> Void
    @objc optional func removed(snapshot: Any, id: Any) -> Void
    @objc optional func get(snapshot: DataSnapshot) -> Void
}



protocol FireBaseRepository {
    associatedtype T
    
    func added(snapshot: DataSnapshot) -> T
//    func updated(snapshot: DataSnapshot, id: Any, state: T) -> T
//    func removed(snapshot: DataSnapshot, state: T) -> T
}
