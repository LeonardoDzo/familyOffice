//
//  DatesModel.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 23/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase


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
    
    var id: String!
    var title: String!
    var description: String!
    var date: Int!
    var endDate: Int!
    var priority: Int!
    var members = [memberEvent]()
    var location: Location? = nil
    var creator: String!
    var dates : NSDictionary!
    //var type: String! = "Home"
    var repeatmodel: repeatEvent!
    
    init() {
        self.id = ""
        self.title = ""
        self.description = ""
        self.date = Date().toMillis()
        self.endDate = Date().addingTimeInterval(60 * 60).toMillis()
        self.priority = 0
        self.members = []
        self.creator = store.state.UserState.user?.id!
        self.repeatmodel = repeatEvent()
    }
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! NSDictionary
        self.title = snapshotValue.exist(field: Event.kTitle)
        self.id = snapshot.key
        self.description = snapshotValue.exist(field: Event.kDescription)
        self.date = snapshotValue.exist(field: Event.kDate)
        self.endDate = snapshotValue.exist(field: Event.kEndDate)
        self.priority = snapshotValue.exist(field: Event.kPriority)
        
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
            
        ]
    }
}

protocol EventBindable: AnyObject {
    var event: Event! { get set }
    var descriptionLabel: UILabel! {get}
    var dateLabel: UILabel! {get}
    var endDateLabel: UILabel! {get}
    var locationLabel: UILabel! {get}
    var titleLabel: UILabel! {get}
    var titleTxtField: UITextField! {get}
    var imageTime : UIImageView! {get}
    var endateTxtField: UITextField! {get}
    var ubicationLabel: UITextField! {get}
    var repeatLabel: UILabel! {get}
    var endRepeat: UILabel! {get}
    var descriptionTxtField: UITextField! {get}
    var startDateTxtfield: UITextField! {get}
}

extension EventBindable {
    // Make the views optionals
    
    var dateLabel: UILabel! {
        return nil
    }
    var startDateTxtfield: UITextField! {return nil}
    
    var endDateLabel: UILabel! {
        return nil
    }
    
    var locationLabel: UILabel! {
        return nil
    }
    var titleLabel: UILabel! {
        return nil
    }
    var descriptionLabel: UILabel! {
        return nil
    }
    var descriptionTxtField: UITextField! {return nil}
    var imageTime: UIImageView! {
        return nil
    }
    var endateTxtField: UITextField! {return nil}
    var ubicationLabel: UITextField! {return nil}
    var repeatLabel: UILabel! {return nil}
    var endRepeat: UILabel! {return nil}
    var titleTxtField: UITextField! {return nil}
    
    // Bind
    
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
        if let endDateLabel = self.endDateLabel {
            endDateLabel.text = Date(timeIntervalSince1970: TimeInterval(event.endDate)).string(with: .dayMonthYearHourMinute)
        }
        if let endateTxtField = self.endateTxtField {
            endateTxtField.text = Date(timeIntervalSince1970: TimeInterval(event.endDate)).string(with: .dayMonthYearHourMinute)
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
        
        if let dateLabel = self.dateLabel {
            dateLabel.text =  Date(timeIntervalSince1970: TimeInterval(event.date)).string(with: .dayMonthYearHourMinute)
        }
        if let startDateTxtfield = self.startDateTxtfield {
            startDateTxtfield.text =  Date(timeIntervalSince1970: TimeInterval(event.date)).string(with: .dayMonthYearHourMinute)
        }
        if let repeatLabel = self.repeatLabel {
            repeatLabel.text = event.repeatmodel.frequency
        }
        
    }
}




