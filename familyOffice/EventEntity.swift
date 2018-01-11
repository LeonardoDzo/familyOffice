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
    dynamic var details: String = ""
    dynamic var isAllDay: Bool? = nil
    dynamic var priority: Priority? = nil
    dynamic var father: EventEntity? = nil
    dynamic var changesforAll: Bool = false
    dynamic var isDeleted: Bool = false
    var following = List<EventEntity>()
    var members = List<memberEventEntity>()
    let myEvents = List<EventEntity>()
    let admins = List<RealmString>()
    dynamic var startdate: Int = 0
    dynamic var enddate: Int = 0
    
    func isChild() -> Bool {
     
        return self.father == nil ? true : self.father!.id != self.id
    }
    
    func getFather() -> EventEntity? {
        return isChild() ? self.father : self
    }
    
    private enum CodingKeys: String, CodingKey {
        case title,
        details,
        startdate,
        enddate,
        changesforAll,
        isAllDay,
        priority,
        creator,
        repeatmodel,
        eventtype,
        id,
        location,
        isDeleted
    }
    
    private enum ArraysKeys: String, CodingKey {
        case members,
        following,
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
        self.changesforAll = try container.decode(Bool.self, forKey: .changesforAll)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
        //Optionals
        self.creator = try container.decodeIfPresent(String.self, forKey: .creator)
        self.details = try container.decodeIfPresent(String.self, forKey: .details) ?? ""
        self.repeatmodel = try container.decodeIfPresent(repeatEntity.self, forKey: .repeatmodel)
        self.eventtype = (try container.decodeIfPresent(eventType.self, forKey: .eventtype))!
        self.isAllDay = try container.decodeIfPresent(Bool.self, forKey: .isAllDay)
        self.priority = try container.decodeIfPresent(Priority.self, forKey: .priority)
        self.title = try container.decode(String.self, forKey: .title)
        self.location = try container.decodeIfPresent(Location.self, forKey: .location)
        
        if let value = try arrayscont.decodeIfPresent([String:EventEntity].self, forKey: .following)?.map({ (_, event) -> EventEntity in
            return event
        }) {
            self.following.append(objectsIn: value)
        }
        
        if let value = try arrayscont.decodeIfPresent([String: memberEventEntity].self, forKey: .members)?.flatMap({ (_, member) -> memberEventEntity in
            return member
        }){
            self.members.append(objectsIn: value)
        }
        if let val = try arrayscont.decodeIfPresent([String: Bool].self, forKey: .admins)?.getKeysRealmString {
            self.admins.append(objectsIn: val)
        }
        self.father = nil
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    func update(date: Int, repeatM: repeatEntity?) -> Void {
        let father = self.father == nil ? self : self.father
        if repeatM != nil {
            guard repeatM?.frequency.rawValue != 0 else{
                return
            }
            print(self.isChild())
            //CAMBIAR FORMA DE ELIMINAR
            let removeevents = rManager.realm.objects(EventEntity.self).filter("father = %@ AND startdate >= %@", father!, date)
            removeevents.forEach({ (event) in
                if event.id != self.id {
                    try! rManager.realm.write {
                        rManager.realm.delete(event)
                    }
                }
            })
            
            print(self)
            self.createDates(repeatM: repeatM!, startDate: date)
        }
        guard let parent = father, parent.following.count > 0 else {
            return
        }
        parent.following.filter("startdate > %@", date).sorted(byKeyPath: "startdate").forEach({ (event) in
            self.updateEvents(following: event)
        })
        
        
    }
    
    func updateEvents(following: EventEntity) {
        
        let father = self.father == nil ? self : self.father
        guard let parent = father else {
            return
        }
        let events = rManager.realm.objects(EventEntity.self).filter("father = %@ AND startdate >= %@", parent, following.startdate).sorted(byKeyPath: "startdate")
        events.enumerated().forEach { (index, event) in
            if var json = event.toJSON(), !parent.following.contains(where: {$0.id == event.id}) {
                if following.changesforAll || event.id == following.id {
                    let id = event.id
                    let startdate = event.startdate
                    let enddate = event.enddate
                    if let eventwithchanges = following.todictionary() {
                        json.update(other: eventwithchanges)
                        json["id"] = id
                        json["startdate"] = startdate
                        json["enddate"] = enddate
                        
                        if let data = json.jsonToData() {
                            let eventchanged = try! JSONDecoder().decode(EventEntity.self, from: data)
                            eventchanged.father = parent
                            rManager.save(objs: eventchanged)
                        }
                    }
                }
                if event.repeatmodel != nil {
                    self.update(date: event.startdate, repeatM: event.repeatmodel!)
                }
            }
            
        }
    }
    
    func createDates(repeatM: repeatEntity, startDate: Int, until: Int = 30) {
        var startDate : Int? = startDate
        var i = until
        print(self)
        let difference = self.enddate - self.startdate
        while startDate != nil && i > 0 {
            startDate = nextDate(currentDate: startDate!, repeatM: repeatM)
            if startDate != nil {
                let id = self.id + String(startDate!)
                var event = rManager.realm.object(ofType: EventEntity.self, forPrimaryKey: id)
                if  event == nil  {
                    event = EventEntity()
                    event?.id = id
                    event?.startdate = startDate!
                    event?.enddate = startDate! + difference
                    event?.eventtype = self.eventtype
                }
                try! rManager.realm.write {
                    event?.father = self
                }
                rManager.save(objs: event!)
            }
            i = i - 1
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
