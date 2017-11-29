//
//  repeatGoalModel.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 13/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

struct repeatGoal: repeatProtocol, Codable {
    static let kFrequency = "frequency"
    static let kdays = "days"
    var frequency: Frequency!
    var days : [String]! = []
    var interval: Int!
    init() {
        self.frequency = .never
    }
    enum CodingKeys: String, CodingKey {
        case frequency, days, interval
    }

    init(_ snapvalue: NSDictionary) {
        let string : String! = snapvalue.exist(field: repeatGoal.kdays)
        self.days = string.components(separatedBy: ",")
        self.frequency = Frequency(rawValue: snapvalue.exist(field: repeatGoal.kFrequency))
    }
    
    func toDictionary() -> NSDictionary {
        return [
            repeatGoal.kdays : self.days.joined(separator: ","),
            repeatGoal.kFrequency : self.frequency.rawValue
        ]
    }
}
