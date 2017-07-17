//
//  repeatGoalModel.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 13/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

struct repeatGoal {
    static let kmode = "mode"
    static let kdays = "days"
    
    var mode = ""
    var days = [String]()
    
    init() {
        self.mode = ""
    }
    
    init(_ snapvalue: NSDictionary) {
        let string : String! = service.UTILITY_SERVICE.exist(field: repeatGoal.kdays, dictionary: snapvalue)
        self.days = string.components(separatedBy: ",")
        self.mode = service.UTILITY_SERVICE.exist(field: repeatGoal.kmode, dictionary: snapvalue)
    }
    
    func toDictionary() -> NSDictionary {
        return [
            repeatGoal.kdays : self.days.joined(separator: ","),
            repeatGoal.kmode : self.mode
        ]
    }
}
