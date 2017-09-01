//
//  repeatModel.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 08/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import Foundation


struct repeatEvent: repeatTypeEvent {
    static let kFrequency = "frequency"
    static let kDays = "days"
    static let kEnd = "endRepeat"
    static let kinterval = "interval"
    
    var frequency: Frequency!
    var interval: Int!
    var days: [String]!
    var end: Int!
    
    init() {
        self.end = 0
        self.days = []
        self.frequency = .daily
        self.interval = 1
    }
    
    init(snapshot: NSDictionary) {
        self.frequency = Frequency(rawValue: snapshot.exist(field: repeatEvent.kFrequency)!)
        if let string : String = snapshot.exist(field: repeatEvent.kDays) {
            self.days = string.components(separatedBy: ",")
        }
        self.end = snapshot.exist(field: repeatEvent.kEnd)
    }
    
    func toDictionary() -> NSDictionary {
        
        return [
            repeatEvent.kFrequency : self.frequency.hashValue,
            repeatEvent.kinterval : self.interval,
            repeatEvent.kEnd: self.end,
            repeatEvent.kDays : self.days.joined(separator: ",")
        ]
    }
}
