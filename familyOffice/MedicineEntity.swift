//
//  MedicineEntity.swift
//  familyOffice
//
//  Created by Nan Montaño on 30/nov/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class MedicineEntity : Object, Serializable {
    dynamic var id: String = ""
    dynamic var family: String = ""
    dynamic var name: String = ""
    dynamic var indications: String = ""
    dynamic var dosage: String = ""
    dynamic var restrictions: String = ""
    dynamic var moreInfo: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func toJSON() -> [String : Any]? {
        return [
            "name": name,
            "moreInfo": moreInfo,
            "indications": indications,
            "dosage": dosage,
            "restrictions": restrictions
        ]
    }
}
