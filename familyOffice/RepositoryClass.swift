//
//  ListenersClass.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 07/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import FirebaseDatabase

@objc protocol repository : class {
    
    func added(snapshot: DataSnapshot) -> Void
    func updated(snapshot: DataSnapshot, id: Any) -> Void
    func removed(snapshot: DataSnapshot) -> Void
    @objc optional func removed(snapshot: Any, id: Any) -> Void
    @objc optional func get(snapshot: DataSnapshot) -> Void
}
