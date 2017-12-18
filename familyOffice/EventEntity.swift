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
class EventEntity: Object, Codable, Serializable {
    
    dynamic var id: String! = ""
    
   
    dynamic var location: Location? = nil
    dynamic var creator: String? = nil
    dynamic var eventtype: eventType = .Default
    dynamic var repeatmodel: repeatEntity? = nil
    dynamic var title = ""
    dynamic var details: String? = nil
    dynamic var isAllDay: Bool? = nil
    dynamic var priority: Priority? = nil
    dynamic var father: EventEntity? = nil
    dynamic var changesforAll = false
    var following = List<EventEntity>()
    var members = List<memberEventEntity>()
    let myEvents = List<EventEntity>()
    let admins = List<RealmString>()
    dynamic var startdate: Int = 0
    dynamic var enddate: Int = 0

    
    private enum CodingKeys: String, CodingKey {
        case title,
        details,
        startdate,
        enddate,
        isAllDay,
        priority,
        creator,
        repeatmodel,
        eventtype,
        id,
        location
    }
    
    private enum ArraysKeys: String, CodingKey {
        case members,
        followings,
        admins
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
        self.eventtype = (try container.decodeIfPresent(eventType.self, forKey: .eventtype))!
        self.isAllDay = try container.decodeIfPresent(Bool.self, forKey: .isAllDay)
        self.priority = try container.decodeIfPresent(Priority.self, forKey: .priority)
        self.title = try container.decode(String.self, forKey: .title)
        self.location = try container.decodeIfPresent(Location.self, forKey: .location)
        
        if let value = try arrayscont.decodeIfPresent([EventEntity].self, forKey: .followings) {
            self.following.append(objectsIn: value)
        }
      
        if let value = try arrayscont.decodeIfPresent([String: memberEventEntity].self, forKey: .members)?.flatMap({ (_, member) -> memberEventEntity in
            return member
        }){
            self.members.append(objectsIn: value)
        }
        if let val = try arrayscont.decodeIfPresent([String: Bool].self, forKey: .admins)?.map({ (key, _ ) -> RealmString in
            return RealmString(value: key)
        }) {
            self.admins.append(objectsIn: val)
        }
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    func update(date: Int, repeatM: repeatEntity) -> Void {
        guard repeatM.frequency.rawValue != 0 else{
            return
        }
        
        let removeevents = rManager.realm.objects(EventEntity.self).filter("father = %@ AND startdate >= %@", self, date)
        try! rManager.realm.write {
            rManager.realm.delete(removeevents)
        }
        
        self.createDates(repeatM: repeatM, startDate: date)
        
        guard following.count > 0 else {
            return
        }
        var changes : [String:Any] = [:]
        self.myEvents.enumerated().forEach { (index, event) in
            
            if var json = event.toJSON() {
                json.update(other: changes)
                rManager.save(objs: event)
                if let val = following.first(where: {$0.id == event.id})?.toJSON() {
                    json.update(other: val)
                    if let data = json.jsonToData() {
                        do {
                            let event = try JSONDecoder().decode(EventEntity.self, from: data)
                            if event.changesforAll {
                                changes = json
                            }
                            rManager.save(objs: event)
                            if event.repeatmodel != nil {
                                for index in (index+1)..<self.myEvents.count {
                                    self.myEvents.remove(at: index)
                                    rManager.deteObject(objs: self.myEvents[index])
                                }
                                update(date: event.startdate, repeatM: event.repeatmodel!)
                            }
                        }catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func createDates(repeatM: repeatEntity, startDate: Int, until: Int = 30) {
        var startDate : Int? = startDate
        var i = until
        let difference = self.enddate - self.startdate
        while startDate != nil && i > 0 {
            let event = EventEntity()
            startDate = nextDate(currentDate: startDate!, repeatM: repeatM)
            if startDate != nil {
                event.id = self.id + String(startDate!)
                event.startdate = startDate!
                event.enddate = startDate! + difference
                event.father = self
              
                try! rManager.realm.write {
                    if !self.myEvents.contains(event) {
                        self.myEvents.append(event)
                    }
                }
                i-=1
            }
            
        }
    }
    
    func nextDate(currentDate: Int,repeatM: repeatEntity?) -> Int? {
        guard repeatM != nil else { return nil }
        
        let calendar = Calendar.current
        var next = Date(currentDate)
        //let days = repeatM?._days.map({$0.value.isEmpty ? calendar.component(.weekday, from: next) : Int($0.value)!}) ?? []


        if let type = repeatM?.frequency.calendartype  {
            next = calendar.date(byAdding: type, value: 1, to: next!)!
        }
//        if nextDay != -1 {
//            var closestBiggerDay = days.first(where: {$0 > nextDay})
//            if closestBiggerDay == nil  {
//                closestBiggerDay = (days.count > 0 ? days[0] : 0)  + 7
//            }
//            let dayDifference = closestBiggerDay! - nextDay
//            interval *= dayDifference
//        }
        if var end = Date((repeatM?.end)!) {
            let hour = 23 - calendar.component(.hour, from: end)
            end.addTimeInterval(TimeInterval(60*60*hour))
            if let n = next?.toMillis(), n > end.toMillis(){
                return nil
            }
            return next?.toMillis()
        }
       
        return nil
    }
    
     func todictionary() -> [String: Any]? {
        if var json = self.toJSON() {
            json["members"] = self.members.toNSArrayByKey() ?? ""
            json["following"] = self.following.toNSArrayByKey() ?? ""
            json["repeatmodel"] = self.repeatmodel?.toDictionary() ?? nil
            json["admins"] = self.admins.toNSArrayByKey() ?? nil
            return json
        }
        return nil
    }
}
