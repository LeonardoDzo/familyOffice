//
//  UserEntity.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

@objcMembers
class RealmString: Object {
    dynamic var value = ""
    
    convenience required init(value: String) {
        self.init()
        self.value = value
    }
}

@objcMembers
public class UserEntity: Object, Codable, Serializable {
    dynamic var id: String = ""
    dynamic var email: String = "Sin email"
    dynamic var name : String = "Sin Nombre"
    dynamic var phone: String = ""
    dynamic var photoURL: String = ""
    dynamic var familyActive : String = ""
    dynamic var rfc : String = ""
    dynamic var nss : String = ""
    dynamic var curp : String = ""
    dynamic var birthday: String = ""
    dynamic var address : String = ""
    dynamic var bloodtype: String = ""
    var families = List<RealmString>()
    var tokens = List<RealmString>()
    var events = List<RealmString>()
    // var health: Health!
    
    override public static func primaryKey() -> String? {
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
             bloodtype,
             familyActive
    }

    private enum Mykeys: String, CodingKey {
        case families, events, tokens
    }
    
    convenience required public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: Mykeys.self)
        let container2 = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container2.decode(String.self, forKey: .id)
        name = try container2.decode(String.self, forKey: .name)
        phone = try container2.decode(String.self, forKey: .phone)
        photoURL = try container2.decode(String.self, forKey: .photoURL)
        familyActive = (try container2.decodeIfPresent(String.self, forKey: .familyActive)) ?? ""
        rfc = try container2.decode(String.self, forKey: .rfc)
        nss = try container2.decode(String.self, forKey: .nss)
        curp = try container2.decode(String.self, forKey: .curp)
        birthday = try container2.decode(String.self, forKey: .birthday)
        address = try container2.decode(String.self, forKey: .address)
        bloodtype = try container2.decode(String.self, forKey: .bloodtype)
        
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .families)?.map({ (key, _ ) -> RealmString in
            return RealmString(value: key)
        }) {
            self.families.append(objectsIn: val)
        }
    
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .events)?.map({ (key, _) -> RealmString in
              return RealmString(value: key)
        }) {
            self.events.append(objectsIn: val)
        }
        
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .tokens)?.map({ (key, _) -> RealmString in
            return RealmString(value: key)
        }) {
            self.tokens.append(objectsIn: val)
        }
    }

    func isUserLogged() -> Bool {
        return Auth.auth().currentUser?.uid == self.id
    }
}

extension List {
    func toNSArrayByKey<T>(ofType: T.Type) -> [String : Bool]? {
        if self.ElementType == ofType {
            var dic : [String:Bool] = [:]
            self.forEach({ (key) in
                if key is String {
                    dic[key as! String] = true
                }
            })
            return dic
            
        }
        return nil
    }
    func toNSArrayByKey() -> [String : Bool]? {
        var dic : [String:Bool] = [:]
        self.forEach({ (key ) in
            if let val = key as? RealmString {
                dic[val.value] = true
            }
        })
        return dic
    }
    
    var ElementType: Element.Type {
        return Element.self
    }
}
extension NSArray {
    func toJSON() -> [String:Any]? {
        let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        return try? JSONSerialization.jsonObject(with: data!) as! [String:Any]
    }
}


