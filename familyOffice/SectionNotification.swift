//
//  Section.swift
//  familyOffice
//
//  Created by miguel reina on 18/04/17.
//  Copyright © 2017 Miguel Reina. All rights reserved.
//

import Foundation

struct SectionNotification {
    
    let date: String!
    var record : [NotificationModel] = []
    
    init(date: String, record: Array<NotificationModel>) {
        self.date = date
        self.record = record
    }
    
    
}
