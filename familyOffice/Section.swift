//
//  Section.swift
//  familyOffice
//
//  Created by miguel reina on 18/04/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

struct Section_Record {
    
    let date: String!
    var record : [Record] = []
    
    init(date: String, record: Array<Record>) {
        
        self.date = date
        self.record = record

    }

    
}
