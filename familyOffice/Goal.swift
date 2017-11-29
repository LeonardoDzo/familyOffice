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
import Realm
enum GoalCategory: Int {
    case sport, religion, school, business, eat, health
}

enum GoalType: Int {
    case personal, familiar
}


struct Goal: Serializable   {
   
    
    typealias  g = Goal
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
    static let kFollow = "follows"
    
    
    var id:String!
    var title: String?
    var type: Int?
    var category: Int?
    var photo: String?
    var endDate: Int?
    var done: Bool? = false
    var note: String?
    var creator: String?
    var startDate : Int!
    var members = [String:Int]()
    var repeatGoalModel : repeatGoal?
    var list = [Goal]()
    
    init() {
        self.title = ""
        self.endDate = Date().toMillis()
        self.startDate =  Date().toMillis()
        self.creator = (userStore?.id)!
        self.type = 0
        self.repeatGoalModel = repeatGoal()
    }
    init(_ startDate: Int) {
        self.startDate = startDate
    }
    
    
    init(snapshot: DataSnapshot) throws {
        let snapshotValue = snapshot.value as! NSDictionary
        if let map = snapshotValue.jsonToData() {
            self = try JSONDecoder().decode(Goal.self, from: map)
        }
        self.id = snapshot.key
        guard let follow = snapshotValue[g.kFollow] as? NSDictionary else {
            self.updateGoals(follow: nil, date: self.startDate, repeatModel: self.repeatGoalModel!)
            return
        }
        self.updateGoals(follow: follow, date: self.startDate, repeatModel: self.repeatGoalModel!)
    }
    
    mutating func updateGoals(follow: NSDictionary?, date: Int, repeatModel: repeatGoal) -> Void {
        self.getDates(date, repeatModel: repeatModel)
        
        guard follow != nil else {
            return
        }
        
         self.list.enumerated().forEach({
            index, goal in
            if let value = follow?.value(forKey: String(goal.startDate)) as? NSDictionary {
                
                if let map = value.jsonToData() {
                    let copy  = try! JSONDecoder().decode(Goal.self, from: map)
                    self.list[index] = copy
                    if self.list[index].repeatGoalModel != nil {
                        follow?.setValue(nil, forKey: String(goal.startDate))
                        for index in index..<self.list.count {
                            self.list.remove(at: index)
                        }
                        updateGoals(follow: follow, date: self.list[index].startDate, repeatModel: self.list[index].repeatGoalModel!)
                    }
                }
              
               
            }
        })
    }
    
    mutating func getDates(_ date: Int, repeatModel: repeatGoal) -> Void {
        var date : Int? = date
        var i = 500
        while((date != nil) && i > 0){
            var goal = Goal(date!)
            goal.members = members
            date = nextDate(currentDate: date!, repeatGoal: self.repeatGoalModel, endDate: self.endDate!);
            self.list.append(goal)
            i-=1;
        }
        
    }
    func nextDate(currentDate: Int, repeatGoal: repeatGoal?, endDate: Int) -> Int? {
        if repeatGoal == nil {
            return nil
        }
        let calendar = Calendar.current
        var next = Date(timeIntervalSince1970: TimeInterval(currentDate/1000));
        
        let days = repeatGoal?.days.map({$0.isEmpty ? calendar.component(.weekday, from: next) : Int($0)!}) ?? []

        switch (repeatGoal?.frequency)! {
        case .never:
            return nil
        case .daily:
            if let value = repeatGoal?.frequency.value {
                next.addTimeInterval(TimeInterval(value))
                if next.toMillis() >= endDate {
                    return nil
                }
                return next.toMillis()
            }
            return nil
        case .weekly:
            let nextDayOfTheWeek = calendar.component(.weekday, from: next)
            var closestBiggerDay = days.first(where: {$0 > nextDayOfTheWeek})
            
            if closestBiggerDay == nil  {
                closestBiggerDay = (days.count > 0 ? days[0] : 0)  + 7
            }
            let dayDifference = closestBiggerDay! - nextDayOfTheWeek
            let interval = TimeInterval(Frequency.daily.value! * dayDifference)
            next.addTimeInterval(interval)
            print(next, Date(timeIntervalSince1970: TimeInterval(endDate/1000)))
            let hour = 23 - calendar.component(.hour, from: Date(endDate)!)
            var end = Date(endDate)!
            end.addTimeInterval(TimeInterval(60*60*hour))
            if next.toMillis() > end.toMillis(){
                return nil
            }
            return next.toMillis()
        case .monthly:
            let nextDayOfTheMonth = Calendar.current.component(.weekOfMonth, from: next)
            var closestBiggerDay = days.first(where: {$0 > nextDayOfTheMonth})
            if closestBiggerDay == nil {
                let current = Date(timeIntervalSince1970: TimeInterval(currentDate/1000))
                let lastDayOfTheMonth = Calendar.current.component(.weekOfMonth, from: current.endOfMonth())
                closestBiggerDay = days[0] + lastDayOfTheMonth;
            }
            let dateDifference = closestBiggerDay! - nextDayOfTheMonth;
            let interval = TimeInterval(Frequency.daily.value! * dateDifference)
            next.addTimeInterval(interval)
          
            let hour = calendar.component(.hour, from: Date(endDate)!) - 23
            let end = Date(endDate)!.addingTimeInterval(TimeInterval(60*60*hour))

            if next.toMillis() > end.toMillis() {
                return nil
            }
            return next.toMillis()
        default:
            return nil
        }
        
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

