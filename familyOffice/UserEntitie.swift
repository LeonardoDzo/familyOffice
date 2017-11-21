//
//  UserEntitie.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

@objcMembers
class UserEntitie: Object, Codable, Serializable {
    dynamic var id: String = ""
    dynamic var email: String = "Sin email"
    dynamic var name : String = "Sin Nombre"
    dynamic var phone: String = "Sin Número"
    dynamic var photoURL: String = ""
    dynamic var familyActive : String = ""
    dynamic var rfc : String = ""
    dynamic var nss : String = ""
    dynamic var curp : String = ""
    dynamic var birthday: String = ""
    dynamic var address : String = ""
    dynamic var bloodtype: String = ""
    dynamic let families = List<String>()
    dynamic let tokens = List<String>()
    dynamic let events = List<String>()
    // var health: Health!
    
    override static func primaryKey() -> String? {
        return "id"
    }

    private enum CodingKeys: String, CodingKey {
        case id,
             name,
             phone,
             photoURL,
             rfc,
             nss,
             curp,
             birthday,
             address,
             bloodtype
    }

    private enum Mykeys: String, CodingKey {
        case families, events, tokens
    }
    
    func setLists(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Mykeys.self)
        
        self.families.append(objectsIn: try container.decode([String: Any].self, forKey: .families).map({ (key, _ ) -> String in
            return key
        }))
        
        self.events.append(objectsIn: try container.decode([String: Any].self, forKey: .events).map({ (key, _) -> String in
            return key
        }))
        
        self.tokens.append(objectsIn:try container.decode([String: Any].self, forKey: .tokens).map({ (key, _) -> String in
            return key
        }))
    }
    func familiesJson() -> NSArray {
        return [families.map({ (key) -> [String: Bool] in
                return [key: true]
            })]
        
    }
    func eventsJson() -> NSArray {
        return [ events.map({ (key) -> [String: Bool] in
                return [key: true]
            }) ]
        
    }
    func tokensJson() -> NSArray {
        return  [ tokens.map({ (key) -> [String: Bool] in
                return [key: true]
            })]
    }
    
    func isUserLogged() -> Bool {
        return Auth.auth().currentUser?.uid == self.id
    }
}
