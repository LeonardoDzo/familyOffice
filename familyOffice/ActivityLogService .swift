//
//  HistoryService .swift
//  familyOffice
//
//  Created by Leonardo Durazo on 01/02/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class ActivityLogService {
    public var activityLog : [Record] = []
    public var sec : [Section_Record] = []
    var handle: UInt!
    private init() {
    }
    
    public static func Instance() -> ActivityLogService {
        return instance
    }
    
    private static let instance : ActivityLogService = ActivityLogService()
    
    func create(id: String, activity: String, photo:String, type: String ) -> Void {
        let key = Constants.FirDatabase.REF_ACTIVITY.child(id).childByAutoId().key
        let record = Record(id: key, activity: activity, timestamp: Utility.Instance().getDate(), type: type, photoURL: photo)
        Constants.FirDatabase.REF_ACTIVITY.child("\(id)/\(key)").setValue(record.toDictionary())
        activityLog.append(record)
    }
    func add(record: Record) -> Void {
        if !self.sec.contains(where: {$0.date == Date(timeIntervalSince1970: abs(record.timestamp)).monthYearLabel}){
            sec.append(Section_Record(date: Date(timeIntervalSince1970: abs(record.timestamp)).monthYearLabel, record: [record]))
        }else{
            if !self.sec.contains(where: {$0.record.contains(where: {$0.id == record.id}) }) {
                sec[sec.count-1].record.append(record)
            }
            //sec[sec.count-1].record.append(record)

        }
        NotificationCenter.default.post(name: notCenter.SUCCESS_NOTIFICATION, object: record)
    }
    
}
