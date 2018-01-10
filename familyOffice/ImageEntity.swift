//
//  ImageEntity.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class ImageEntity : Object {
    dynamic var id: String = ""
    dynamic var data = Data()
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
}
