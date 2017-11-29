//
//  FaqActions.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/25/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct InsertFaqAction: Action {
    static let type = "FAQ_ACTION_INSERT"
    var question: Question!
    init(question: Question){
        self.question = question
    }
}

struct UpdateFaqAction: Action {
    var question: Question!
    init(question: Question){
        self.question = question
    }
}

struct DeleteFaqAction: Action {
    static let type = "FAQ_ACTION_DELETE"
    var question: Question!
    init(question: Question){
        self.question = question
    }

}
