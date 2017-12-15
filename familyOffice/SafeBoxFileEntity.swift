//
//  SafeBoxFileEntity.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazat on 12/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

@objcMembers
public class SafeBoxFileEntity: Object, Codable, Serializable {
    dynamic var id: String = ""
    dynamic var filename: String = ""
    dynamic var type: String = ""
    dynamic var downloadUrl = ""
    dynamic var thumbnail = ""
    dynamic var parentId = ""
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
