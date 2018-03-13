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
    convenience required init(_ id: String) {
        self.init()
        self.value = id
    }
}
@objcMembers
class assistantpending: Object {
    dynamic var key = ""
    dynamic var value = false
   
    convenience required init(_ value: Bool,_ key: String) {
        self.init()
        self.value = value
        self.key = key
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
    dynamic var safeboxPwd: String = ""
    dynamic var address : String = ""
    dynamic var bloodtype: String = ""
    var families = List<RealmString>()
    var tokens = List<RealmString>()
    var events = List<RealmString>()
    dynamic var assistants = List<assistantpending>()
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
             safeboxPwd,
             bloodtype,
             familyActive
    }

    private enum Mykeys: String, CodingKey {
        case families, events, tokens, fcm, assistants
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
        safeboxPwd = try container2.decode(String.self, forKey: .safeboxPwd)
        address = try container2.decode(String.self, forKey: .address)
        bloodtype = try container2.decode(String.self, forKey: .bloodtype)
        
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .families)?.getKeysRealmString{
            self.families.append(objectsIn: val)
        }
    
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .events)?.getKeysRealmString {
            self.events.append(objectsIn: val)
        }
        
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .tokens)?.getKeysRealmString {
            self.tokens.append(objectsIn: val)
        }
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .tokens)?.getKeysRealmString {
            self.tokens.append(objectsIn: val)
        }
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .tokens)?.getKeysRealmString {
            self.tokens.append(objectsIn: val)
        }
        if let val = try container.decodeIfPresent([String: Bool].self, forKey: .assistants)?.assistanPendings {
            self.assistants.append(objectsIn: val)
        }
    }

    func isUserLogged() -> Bool {
        return Auth.auth().currentUser?.uid == self.id
    }
    func update(snap: [String: Any]) -> Bool{
        do {
        var user : [String: Any]? = nil
        if var val = self.toJSON() {
            val["families"] = self.families.toNSArrayByKey() ?? []
            val["events"] = self.events.toNSArrayByKey() ?? []
            val["tokens"] = self.tokens.toNSArrayByKey() ?? []
            user = val
            user?.update(other: snap)
            if let data = user?.jsonToData() {
                let editUser = try JSONDecoder().decode(UserEntity.self, from: data)
                rManager.save(objs: editUser)
                return true
            }
        }
        } catch let error {
            print(error)
            return false
        }
        return false
            
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
    func toNSArrayByKey() -> [String : Any]? {
        var dic : [String:Any] = [:]
        self.forEach({ (key ) in
            if let val = key as? RealmString {
                dic[val.value] = true
            }else if let val = key as? memberEventEntity {
                dic[val.id] = val.toJSON()!
            }else if let val = key as? EventEntity {
                dic[val.id] = val.todictionary()
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
