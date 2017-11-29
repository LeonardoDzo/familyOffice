//
//  record.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 01/02/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

struct Record {
    
    static let kRecordIdkey = "id"
    static let kRecordActivykey = "action"
    static let kRecordDatekey = "timestamp"
    static let kRecordPhotokey = "photo"
    static let kRecordTypekey = "type"
    
    let id: String!
    let activity: String!
    let timestamp: Double!
    let type: String!
    var photoURL: String!
    
    init(id: String, activity: String, timestamp: Double, type: String, photoURL: String) {
        
        self.activity = activity
        self.timestamp = timestamp * -1
        self.id = id
        self.photoURL = photoURL
        self.type = type
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! NSDictionary
        self.id = snapshot.key
        self.activity = service.UTILITY_SERVICE.exist(field: Record.kRecordActivykey, dictionary: snapshotValue)
        self.timestamp = service.UTILITY_SERVICE.exist(field: Record.kRecordDatekey, dictionary: snapshotValue)
        self.type = service.UTILITY_SERVICE.exist(field: Record.kRecordTypekey, dictionary: snapshotValue)
        self.photoURL = service.UTILITY_SERVICE.exist(field: Record.kRecordPhotokey, dictionary: snapshotValue)

    }
    func toDictionary() -> NSDictionary {
        return [
            Record.kRecordDatekey : self.timestamp,
            Record.kRecordActivykey : self.activity,
            Record.kRecordPhotokey : self.photoURL,
            Record.kRecordTypekey : self.type
        ]
    }
    
    
}
