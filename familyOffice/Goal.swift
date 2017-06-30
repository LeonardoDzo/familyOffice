//
//  Goal.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit
import Firebase

enum GoalType: Int {
    case sport, religion, school, business, eat, health
}

struct Goal {
    static let ktitle = "title"
    static let ktype = "type"
    static let kphoto = "photo"
    static let kendDate = "endDate"
    static let kdone = "donde"
    static let knote = "note"
    static let kcreator = "creator"
    static let kdateCreated = "dateCreated"
    
    
    var id:String!
    var title: String!
    var type: Int! = 0
    var photo: String! = ""
    var endDate: String!
    var done: Bool! = false
    var note: String! = ""
    var creator: String! = ""
    var dateCreated : Int!
    
    
    init() {
        self.id = ""
        self.title = ""
        self.endDate = Date().addingTimeInterval(60 * 60 * 24).string(with: .InternationalFormat)
        self.dateCreated =  NSDate().timeIntervalSince1970.exponent
        self.creator = service.USER_SERVICE.users[0].id
        self.type = 0
        
    }
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! NSDictionary
        self.id = snapshot.key
        
        self.title = service.UTILITY_SERVICE.exist(field: Goal.ktitle, dictionary: snapshotValue)
        
        self.dateCreated = service.UTILITY_SERVICE.exist(field: Goal.kdateCreated, dictionary: snapshotValue)
        
        self.endDate = service.UTILITY_SERVICE.exist(field: Goal.kendDate, dictionary: snapshotValue )
        
        self.type = GoalType(rawValue: service.UTILITY_SERVICE.exist(field: Goal.ktype, dictionary: snapshotValue )).map { $0.rawValue }
        
        self.note = service.UTILITY_SERVICE.exist(field: Goal.knote, dictionary: snapshotValue)
        
        self.creator = service.UTILITY_SERVICE.exist(field: Goal.kcreator, dictionary: snapshotValue)
        
        self.photo = service.UTILITY_SERVICE.exist(field: Goal.kphoto, dictionary: snapshotValue)
        
        self.done = service.UTILITY_SERVICE.exist(field: Goal.kdone, dictionary: snapshotValue)
    }
    func toDictionary() -> NSDictionary! {
        return [
            Goal.kcreator : self.creator,
            Goal.kdateCreated : self.dateCreated,
            Goal.kdone : self.done,
            Goal.kendDate : self.endDate,
            Goal.ktype : self.type,
            Goal.knote : self.note,
            Goal.ktitle : self.title
        ]
    }
    
    
}

protocol GoalBindable: AnyObject {
    var goal: Goal! {get set}
    var titleLbl: UILabel! {get}
    var dateCreatedLbl: UILabel! {get}
    var endDateDP: UIDatePicker! {get}
    var endDateLbl: UILabel! {get}
    var photo: UIImageView! {get}
    var typeicon : UIImageView! {get}
    var creatorLbl: UILabel! {get}
    var noteLbl: UILabel! {get} 
}
