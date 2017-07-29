//
//  repeatGoalModel.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 13/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

struct repeatGoal: repeatProtocol {
    static let kFrequency = "frequency"
    static let kdays = "days"
    static let keach = "each"
    var frequency: String!
    var days : [String]! = []
    var each: Int!
    init() {
        self.frequency = ""
        self.each = 1
    }
    
    init(_ snapvalue: NSDictionary) {
        let string : String! = snapvalue.exist(field: repeatGoal.kdays)
        self.days = string.components(separatedBy: ",")
        self.frequency = snapvalue.exist(field: repeatGoal.kFrequency)
        self.each = snapvalue.exist(field: repeatGoal.keach)
    }
    
    func toDictionary() -> NSDictionary {
        return [
            repeatGoal.kdays : self.days.joined(separator: ","),
            repeatGoal.kFrequency : self.frequency,
            repeatGoal.keach : self.each
        ]
    }
}
