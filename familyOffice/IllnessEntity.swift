//
//  IllnessEntity.swift
//  familyOffice
//
//  Created by Nan Montaño on 30/nov/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class IllnessEntity : Object, Serializable {
    
    dynamic var id: String = ""
    dynamic var family: String = ""
    dynamic var name: String = ""
    dynamic var medicine: String = ""
    dynamic var dosage: String = ""
    dynamic var moreInfo: String = ""
    dynamic var type: Int = -1
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func toJSON() -> [String : Any]? {
        return [
            "name": name,
            "moreInfo": moreInfo,
            "medicine": medicine,
            "dosage": dosage,
            "type": type
        ]
    }
    
}
