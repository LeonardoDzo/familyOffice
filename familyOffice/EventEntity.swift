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
    dynamic var id: String = ""
    dynamic var title: String = ""
    dynamic var details: String = ""
    dynamic var date: Int  = 0
    dynamic var isAllDay: Bool = false
    dynamic var endDate: Int = 0
    dynamic var priority: Int = 0
    var members = [memberEventEntity]()
    let _members = List<memberEventEntity>()
   // dynamic var location: Location? = nil
    dynamic var creator: String = ""
   // dynamic var dates : NSDictionary
    dynamic var type: eventType! = .Default
    dynamic var repeatmodel: repeatEventEntity!
    
    private enum CodingKeys: String, CodingKey {
        case title,
        details,
        date,
        isAllDay,
        priority,
        creator,
        repeatmodel,
        id,
        members
    }
    override static func ignoredProperties() -> [String] {
        return ["members"]
    }
    
}

@objcMembers
class repeatEventEntity: Object, Codable, Serializable, repeatTypeEvent {
    
    var days: [String]! = []
    dynamic var frequency: Frequency! = .never
    dynamic var interval: Int! = 0
    let _days = List<RealmString>()
    dynamic var end: Int! = -1
    
    
    private enum CodingKeys: String, CodingKey {
        case days,
             frequency,
             interval,
             end
    }
    
    override static func ignoredProperties() -> [String] {
        return ["days"]
    }
    
}
