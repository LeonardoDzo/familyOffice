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
    static let keach = "each"
    
    var frequency: String!
    var each: Int!
    var days: [String]!
    var end: Int!
    
    init() {
        self.end = 0
        self.days = []
        self.frequency = ""
        self.each = 1
    }
    
    init(snapshot: NSDictionary) {
        self.frequency = snapshot.exist(field: repeatEvent.kFrequency)
        if let string : String = snapshot.exist(field: repeatEvent.kDays) {
            self.days = string.components(separatedBy: ",")
        }
        self.end = snapshot.exist(field: repeatEvent.kEnd)
    }
    
    func toDictionary() -> NSDictionary {
        
        return [
            repeatEvent.kFrequency : self.frequency,
            repeatEvent.kEnd: self.end,
            repeatEvent.kDays : self.days.joined(separator: ",")
        ]
    }
}
