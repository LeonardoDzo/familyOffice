//
//  FollowGoal.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 13/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

struct FollowGoal {
    static let kUser = "member"
    let date: String!
    var members = [String: Int]()
    
    init(snapshot: NSDictionary, date: String) {
        for member in snapshot.allKeys as! [String] {
            self.members[member] = snapshot.value(forKey: member) as? Int
        }
        self.date = date
    }
    func toDictionary() -> NSDictionary {
        return [self.date : self.members]
    }

}
