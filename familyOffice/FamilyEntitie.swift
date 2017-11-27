//
//  FamilyEntitie.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import RealmSwift

@objcMembers
class FamilyEntitie : Object, Codable, Serializable {
    dynamic var id : String = Constants.FirDatabase.REF.child("families").childByAutoId().key
    dynamic var name: String = ""
    dynamic var photoURL : String = ""
    dynamic var imageProfilePath: String = ""
    dynamic let admins = List<RealmString>()
    dynamic let members = List<RealmString>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private enum CodingKeys: String, CodingKey  {
        case id,
             name,
             photoURL,
             imageProfilePath
    }
    private enum Mykeys: String, CodingKey  {
        case admins,
        members
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: Mykeys.self)
        let container2 = try decoder.container(keyedBy: CodingKeys.self)
        id = try container2.decode(String.self, forKey: .id)
        name = try container2.decode(String.self, forKey: .name)
        photoURL = try container2.decode(String.self, forKey: .photoURL)
        imageProfilePath = try container2.decode(String.self, forKey: .imageProfilePath)
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .admins)?.map({ (key, _ ) -> RealmString in
            return RealmString(value: key)
        }) {
            self.admins.append(objectsIn: val)
        }
        
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .members)?.map({ (key, _) -> RealmString in
            return RealmString(value: key)
        }) {
            self.members.append(objectsIn: val)
        }
        
    }
}
