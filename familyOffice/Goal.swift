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

enum GoalCategory: Int {
    case sport, religion, school, business, eat, health
}

enum GoalType: Int {
    case personal, familiar
}

struct Goal {
    static let ktitle = "title"
    static let ktype = "type"
    static let kcategory = "category"
    static let kphoto = "photo"
    static let kendDate = "endDate"
    static let kdone = "done"
    static let knote = "note"
    static let kcreator = "creator"
    static let kdateCreated = "startDate"
    static let kMembers = "members"
    static let kRepeat = "repeat"
    static let kFollow = "follow"
    
    
    var id:String!
    var title: String!
    var type: Int! = 0
    var category: Int! = 0
    var photo: String! = ""
    var endDate: Int!
    var done: Bool! = false
    var note: String! = ""
    var creator: String! = ""
    var startDate : Int!
    var members = [String:Int]()
    var repeatGoalModel : repeatGoal!
    var follow = [FollowGoal]()
    
    init() {
        
        self.title = ""
        self.endDate = Date().toMillis()
        self.startDate =  Date().toMillis()
        self.creator = service.USER_SERVICE.users[0].id
        self.type = 0
        self.repeatGoalModel = repeatGoal()
    }
    
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! NSDictionary
        self.id = snapshot.key
        
        self.title = service.UTILITY_SERVICE.exist(field: Goal.ktitle, dictionary: snapshotValue)
        
        self.startDate = service.UTILITY_SERVICE.exist(field: Goal.kdateCreated, dictionary: snapshotValue)
        
        self.endDate = service.UTILITY_SERVICE.exist(field: Goal.kendDate, dictionary: snapshotValue )
        
        self.type = GoalType(rawValue: service.UTILITY_SERVICE.exist(field: Goal.ktype, dictionary: snapshotValue )).map { $0.rawValue }
        
        self.note = service.UTILITY_SERVICE.exist(field: Goal.knote, dictionary: snapshotValue)
        
        self.creator = service.UTILITY_SERVICE.exist(field: Goal.kcreator, dictionary: snapshotValue)
        
        self.photo = service.UTILITY_SERVICE.exist(field: Goal.kphoto, dictionary: snapshotValue)
        
        self.done = service.UTILITY_SERVICE.exist(field: Goal.kdone, dictionary: snapshotValue)
        
        self.members = service.UTILITY_SERVICE.exist(field: Goal.kMembers, dictionary: snapshotValue)
        
        self.category = service.UTILITY_SERVICE.exist(field: Goal.kcategory, dictionary: snapshotValue)
        
        self.repeatGoalModel =  repeatGoal(service.UTILITY_SERVICE.exist(field: Goal.kRepeat, dictionary: snapshotValue))
        
        if let snap = snapshotValue[Goal.kFollow] as? NSDictionary {
            for date in snap.allKeys as! [String] {
                self.follow.append(FollowGoal(snapshot: snap[date] as! NSDictionary, date: date ))
            }
        }
     
    }
    func toDictionary() -> NSDictionary! {
        return [
            Goal.kcreator : self.creator,
            Goal.kdateCreated : self.startDate,
            Goal.kdone : self.done,
            Goal.kendDate : self.endDate,
            Goal.ktype : self.type,
            Goal.knote : self.note,
            Goal.ktitle : self.title,
            Goal.kcategory : self.category,
            Goal.kMembers : self.members,
            Goal.kRepeat : self.repeatGoalModel.toDictionary(),
            Goal.kFollow : NSDictionary(objects: self.follow.map({$0.members}), forKeys: self.follow.map({$0.date}) as! [NSCopying]),

            
        ]
    }
    
    mutating func setId() -> Void {
       self.id = Constants.FirDatabase.REF.childByAutoId().key
    }
    
    
}

protocol GoalBindable: AnyObject {
    var goal: Goal! {get set}
    var titleLbl: UILabel! {get}
    var titleTxt: UITextField! {get}
    var dateCreatedLbl: UILabel! {get}
    var endDateDP: UIDatePicker! {get}
    var endDateLbl: UILabel! {get}
    var photo: UIImageView! {get}
    var typeicon : UIImageView! {get}
    var creatorLbl: UILabel! {get}
    var noteLbl: UILabel! {get}
    var doneSwitch: UISwitch! {get}
    var repeatSwitch: UISwitch! {get}
}

