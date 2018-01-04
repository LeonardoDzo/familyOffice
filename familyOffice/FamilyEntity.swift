//
//  FamilyEntity.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import RealmSwift

@objcMembers
class FamilyEntity : Object, Codable, Serializable {
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
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .admins)?.getKeysRealmString {
            self.admins.append(objectsIn: val)
        }
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .members)?.getKeysRealmString {
            self.members.append(objectsIn: val)
        }
        
    }
    func update(snap: [String: Any]) -> Bool{
        do {
            var family : [String: Any]? = nil
            if var val = self.toJSON() {
                val["admins"] = self.admins.toNSArrayByKey() ?? []
                val["members"] = self.members.toNSArrayByKey() ?? []
                family = val
                family?.update(other: snap)
                if let data = family?.jsonToData() {
                    let editFamily = try JSONDecoder().decode(FamilyEntity.self, from: data)
                    rManager.save(objs: editFamily)
                    return true
                }
            }
        }catch let error {
            print(error)
            return false
        }
        return false
        
    }
    
    override var description: String {
        return self.name
    }
}
