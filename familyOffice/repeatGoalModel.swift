//
//  repeatGoalModel.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 13/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

struct repeatGoal {
    
    var frequency: Frequency!
    var days = [String]()
    var interval: Int!
    var end: Int?

    enum CodingKeys: String, CodingKey {
        case frequency, days, interval
    }

    init(_ snapvalue: NSDictionary) {
    }
    
    func toDictionary() -> NSDictionary {
        return [:]
    }
}
