//
//  repeatGoalModel.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 13/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ObjectMapper
struct repeatGoal: repeatProtocol, Mappable {
    static let kFrequency = "frequency"
    static let kdays = "days"
    var frequency: Frequency!
    var days : [String]! = []
    var interval: Int!
    init() {
        self.frequency = .never
    }
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        frequency <- map[repeatGoal.kFrequency]
        var str: String?
        str = try? map.value(repeatGoal.kdays) ?? ""
        days = str?.components(separatedBy: ",") ?? []
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
