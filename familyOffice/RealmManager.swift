//
//  RealmManager.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import Foundation
import RealmSwift
let rManager = RealmManager.shared


class RealmManager {
    let config = Realm.Configuration(
        
        schemaVersion: 1,
        
        // Set the block which will be called automatically when opening a Realm with
        // a schema version lower than the one set above
        migrationBlock: { migration, oldSchemaVersion in
            
            if oldSchemaVersion == 1 {
                migration.enumerateObjects(ofType: EventEntity.className(), { (old, new) in
                    new?["startdate"] = 0
                    new?["enddate"] = 0
                })
            }
    })
 
    var realm : Realm!
    
    private init(){
        realm = try! Realm(configuration: config)
    }
    static let shared = RealmManager()
    
    /**
     Delete local database
     */
    func deleteDatabase() {
        try! realm.write({
            realm.deleteAll()
        })
    }
    
    /**
     Save array of objects to database
     */
    func saveObjects(objs: [Object]) {
        try! realm.write({
            // If update = true, objects that are already in the Realm will be
            // updated instead of added a new.
            realm.add(objs, update: true)
        })
    }
    
    /**
     Elimina un objeto
    */
    func deteObject(objs: Object) {
        try! realm.write({
            // If update = true, objects that are already in the Realm will be
            // updated instead of added a new.
            realm.delete(objs)
        })
    }
    func save(objs: Object) {
        do{
            try realm.write({
                // If update = true, objects that are already in the Realm will be
                // updated instead of added a new.
                realm.add(objs, update: true)
            })
        }catch let error{
            print("Error: \(error.localizedDescription)")
        }
        
        
    }
    
    /**
     Returs an array as Results<object>?
     */
    func getObjects(type: Object.Type) -> Results<Object>? {
        return realm.objects(type)
    }
}

