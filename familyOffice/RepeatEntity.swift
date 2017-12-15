//
//  RepeatEntity.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 13/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import RealmSwift
@objcMembers
class repeatEntity: Object, Codable, Serializable, repeatProtocol {
    
    var days: String?  = ""
    
    dynamic var frequency: Frequency = .never
    dynamic var interval: Int = 1
    dynamic var end: Int = -1
    let _days = List<RealmString>()
    
    private enum CodingKeys: String, CodingKey {
        case days,
        frequency,
        interval,
        end
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.frequency = try container.decode(Frequency.self, forKey: .frequency)
        self.interval = try container.decode(Int.self, forKey: .interval)
        self.end = try container.decode(Int.self, forKey: .end)
        
        if let val = try container.decodeIfPresent(String.self, forKey: .days)?.components(separatedBy: ",").map({ (key) -> RealmString in
            return RealmString(value: key)
        }) {
            self._days.append(objectsIn: val)
        }
 
    }
    func toDictionary() -> [String:Any]? {
        if var json = self.toJSON() {
            let arrayString = self._days.map({ (rs) -> String in
                return rs.value
            })
            json["days"] = arrayString.joined(separator: ",")
            return json
        }
        return nil
    }
    
    override static func ignoredProperties() -> [String] {
        return ["days"]
    }
    
}

