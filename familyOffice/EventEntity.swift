//
//  EventEntitie.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 28/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift



@objcMembers
class EventEntity: Object, Codable {
    
    /// Required
    dynamic var id: String! = ""
    dynamic var startdate: Int!  = 0
    dynamic var enddate: Int! = 0
    
   // dynamic var location: Location? = nil
    dynamic var creator: String? = nil
    dynamic var type: eventType? = nil
    dynamic var repeatmodel: repeatEntity? = nil
    dynamic var title: String? = "sin título"
    dynamic var details: String? = nil
    dynamic var isAllDay: Bool? = nil
    dynamic var priority: Priority? = nil
    dynamic let father: EventEntity? = nil
    
    var following = List<EventEntity>()
    let members = List<memberEventEntity>()
    

    private enum CodingKeys: String, CodingKey {
        case title,
        details,
        startdate,
        enddate,
        isAllDay,
        priority,
        creator,
        repeatmodel,
        type,
        id
    }
    
    private enum ArraysKeys: String, CodingKey {
        case members,
             followings
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let arrayscont = try decoder.container(keyedBy: ArraysKeys.self)
        
        //Required
        self.id = try container.decode(String.self, forKey: .id)
        self.startdate = try container.decode(Int.self, forKey: .startdate)
        self.enddate = try container.decode(Int.self, forKey: .enddate)
        
        //Optionals
        self.creator = try container.decodeIfPresent(String.self, forKey: .creator)
        self.details = try container.decodeIfPresent(String.self, forKey: .details)
        self.repeatmodel = try container.decodeIfPresent(repeatEntity.self, forKey: .repeatmodel)
        self.type = try container.decodeIfPresent(eventType.self, forKey: .type)
        self.isAllDay = try container.decodeIfPresent(Bool.self, forKey: .isAllDay)
        self.priority = try container.decodeIfPresent(Priority.self, forKey: .priority)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        
        if let value = try arrayscont.decodeIfPresent([EventEntity].self, forKey: .followings) {
            self.following.append(objectsIn: value)
        }
        
        if let value = try arrayscont.decodeIfPresent([memberEventEntity].self, forKey: .members){
            self.members.append(objectsIn: value)
        }
        
    }
    
    override static func ignoredProperties() -> [String] {
        return ["members", "following"]
    }
    

}

@objcMembers
class repeatEntity: Object, Codable, Serializable, repeatProtocol {
    
    var days: String?  = ""
    let _days = List<RealmString>()
    dynamic var frequency: Frequency! = .never
    dynamic var interval: Int? = 0
    dynamic var end: Int? = -1
    
    
    private enum CodingKeys: String, CodingKey {
        case days,
             frequency,
             interval,
             end
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        frequency = try container.decode(Frequency.self, forKey: .frequency)
        interval = try container.decodeIfPresent(Int.self, forKey: .interval)
        end = try container.decodeIfPresent(Int.self, forKey: .end)
        
        if let val = try container.decodeIfPresent(String.self, forKey: .days)?.components(separatedBy: ",").map({ (key) -> RealmString in
            return RealmString(value: key)
        }) {
            self._days.append(objectsIn: val)
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["days"]
    }
    
}
