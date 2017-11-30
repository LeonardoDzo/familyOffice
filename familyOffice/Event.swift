//
//  DatesModel.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 23/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase

public enum EventAvailability : Int {
    
    
    case notSupported
    
    case busy
    
    case free
    
    case tentative
    
    case unavailable
}

public enum EventStatus : Int {
    
    
    case none
    
    case confirmed
    
    case tentative
    
    case canceled
}

enum eventType: Int, GDL90_Enum, Codable  {

    case Default = 0, BirthDay, Meet
    var description: String {
        switch self {
        case .BirthDay:
            return "Cumpleaños"
        case .Meet:
            return "Reunion"
        default:
            return "Default"
        }
    }
}

struct Event {
    
    static let kId = "Id"
    static let kTitle = "title"
    static let kDescription = "description"
    static let kDate = "date"
    static let kEndDate = "endDate"
    static let kPriority = "priority"
    static let kMembers = "members"
    static let kreminder = "reminder"
    static let klocation = "location"
    static let kcreator = "creator"
    static let ktype = "type"
    static let kDates = "dates"
    static let kRepeat = "repeat"
    static let kisAllDay = "isAllDay"
    
    var id: String!
    var title: String!
    var description: String!
    var date: Int!
    var isAllDay: Bool = false
    var endDate: Int!
    var priority: Int!
    var members = [memberEvent]()
    var location: Location? = nil
    var creator: String!
    var dates : NSDictionary!
    var type: eventType!
    var repeatmodel: repeatEvent!
    
    init() {
        self.id = ""
        self.title = ""
        self.description = ""
        self.date = Date().toMillis()
        self.endDate = Date().addingTimeInterval(60 * 60).toMillis()
        self.priority = 0
        self.members = []
        self.creator = userStore?.id!
        self.repeatmodel = repeatEvent()
        self.type = .Default
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! NSDictionary
        self.title = snapshotValue.exist(field: Event.kTitle)
        self.id = snapshot.key
        self.description = snapshotValue.exist(field: Event.kDescription)
        self.date = snapshotValue.exist(field: Event.kDate)
        self.endDate = snapshotValue.exist(field: Event.kEndDate)
        self.priority = snapshotValue.exist(field: Event.kPriority)
        self.isAllDay = snapshotValue.exist(field: Event.kisAllDay)
        
        if let val : Int? = snapshotValue.exist(field: Event.ktype) {
            self.type = eventType(rawValue: val!)
        }else{
            self.type = eventType(rawValue: 0)
        }
        if let members = snapshotValue[Event.kMembers] as? NSDictionary {
            for item in members {
                let member = memberEvent(snapshot: item.value as! NSDictionary, id: item.key as! String)
                self.members.append(member)
            }
        }
        if let xlocation = snapshotValue[Event.klocation] as? NSDictionary {
            self.location = Location(snapshot:xlocation)
        }
        
        if let model = snapshotValue.exist(dic: Event.kRepeat) {
            self.repeatmodel = repeatEvent(snapshot: model)
        }
        self.dates = snapshotValue.exist(dic: Event.kDates)
        self.creator = snapshotValue.exist(field: Event.kcreator)
    }
    
    func toDictionary() -> NSDictionary {
        
        return [
            Event.kTitle : self.title,
            Event.kDescription : self.description,
            Event.kEndDate : self.endDate,
            Event.kDate : self.date,
            Event.kPriority : self.priority,
            Event.kMembers : NSDictionary(objects: self.members.map({$0.toDictionary()}), forKeys: self.members.map({$0.id}) as! [NSCopying]),
            Event.klocation : self.location?.toDictionary() ?? "",
            Event.kcreator : self.creator,
            Event.kRepeat : self.repeatmodel.toDictionary(),
            Event.kisAllDay : self.isAllDay,
            
        ]
    }
}

protocol EventBindable: AnyObject, bind {
    
    var event: Event! { get set }
    
    var descriptionLabel: UILabel! {get}
    var startDateLbl: UILabel! {get}
    var endDateLbl: UILabel! {get}
    var locationLabel: UILabel! {get}
    var titleLabel: UILabel! {get}
    var titleTxtField: UITextField! {get}
    var imageTime : UIImageView! {get}
    var ubicationLabel: UITextField! {get}
    var repeatLabel: UILabel! {get}
    var endRepeat: UILabel! {get}
    var descriptionTxtField: UITextField! {get}
    var typeLbl: UILabel! {get}
    var memberCountLbl: UILabel! {get}
}

extension EventBindable  {
    // Make the views optionals
   
    var startDateLbl: UILabel! {return nil}
    var endDateLbl: UILabel! {return nil}
    var typeLbl: UILabel! {return nil}
    var memberCountLbl: UILabel! {return nil}
    var locationLabel: UILabel! {return nil}
    var titleLabel: UILabel! {return nil}
    var descriptionLabel: UILabel! {return nil}
    var descriptionTxtField: UITextField! {return nil}
    var imageTime: UIImageView! {return nil}
    var ubicationLabel: UITextField! {return nil}
    var repeatLabel: UILabel! {return nil}
    var endRepeat: UILabel! {return nil}
    var titleTxtField: UITextField! {return nil}
    
    // Bind
    
    func bind(sender: Any?) {
        if sender is Event {
            bind(event: sender as! Event)
        }
    }
    
    func bind(event: Event) {
        self.event = event
        bind()
    }
    
    func bind() {
        
        guard let event = self.event else {
            return
        }
        
        if let locationLabel = self.locationLabel {
            if event.location != nil {
                locationLabel.text =  (event.location?.title.isEmpty)! ?  "Sin ubicación" : "\(event.location?.title ?? ""), \(event.location?.subtitle ?? "")"
            }else{
                locationLabel.text =   "Sin ubicación"
            }
            
        }
        if let ubicationLabel = self.ubicationLabel {
            if event.location != nil {
                ubicationLabel.text =  (event.location?.title.isEmpty)! ?  "Sin ubicación" : "\(event.location?.title ?? ""), \(event.location?.subtitle ?? "")"
            }else{
                ubicationLabel.text =   "Sin ubicación"
            }
            
        }
        if let endDateLbl = self.endDateLbl {
            var formatter: DateFormatter!
            if event.isAllDay {
                formatter = .dayMonthAndYear
            }else{
                formatter = .dayMonthYearHourMinute
            }
            
            let date = Date(timeIntervalSince1970: TimeInterval(event.endDate/1000))
           
            endDateLbl.text = date.string(with: formatter)
            
        }
        if let memberCountLbl = self.memberCountLbl {
            memberCountLbl.text = String(event.members.count)
        }
        if let titleTxtField = self.titleTxtField {
            titleTxtField.text = event.title
        }
        if let titleLabel = self.titleLabel {
            titleLabel.text = event.title
        }
        if let descriptionTxtField = self.descriptionTxtField {
            descriptionTxtField.text = event.description
        }
        if let descriptionLabel = self.descriptionLabel {
            descriptionLabel.text = event.description
        }
        if let typeLbl = self.typeLbl {
            typeLbl.text = event.type.description
        }
        
        if let startDateLbl = self.startDateLbl {
            var formatter: DateFormatter!
            if event.isAllDay {
                formatter = .dayMonthAndYear
            }else{
                formatter = .dayMonthYearHourMinute
            }
            let date = Date(timeIntervalSince1970: TimeInterval(event.date/1000))
          
            startDateLbl.text = date.string(with: formatter)
            
        }
        
        if let repeatLabel = self.repeatLabel {
            repeatLabel.text = event.repeatmodel.frequency.description
        }
        if let endRepeat = self.endRepeat {
            if event.repeatmodel.end > 0 {
                endRepeat.text = Date(timeIntervalSince1970: TimeInterval(event.repeatmodel.end/1000)).string(with: .dayMonthAndYear)
            }else{
                endRepeat.text = "Nunca"
            }
        }
        
    }
}




