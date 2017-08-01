//
//  FaqActions.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/25/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder

let faqActionTypeMap: TypeMap = [
    InsertFaqAction.type: InsertFaqAction.self,
    UpdateFaqAction.type: UpdateFaqAction.self,
    DeleteFaqAction.type: DeleteFaqAction.self]

struct InsertFaqAction: StandardActionConvertible {
    static let type = "FAQ_ACTION_INSERT"
    var question: Question!
    init(question: Question){
        self.question = question
    }
    init(_ standardAction: StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertFaqAction.type, payload: [:], isTypedAction: true)
    }
}

struct UpdateFaqAction: StandardActionConvertible {
    static let type = "FAQ_ACTION_UPDATE"
    var question: Question!
    init(question: Question){
        self.question = question
    }
    init(_ standardAction: StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: UpdateFaqAction.type, payload: [:], isTypedAction: true)
    }
}

struct DeleteFaqAction: StandardActionConvertible {
    static let type = "FAQ_ACTION_DELETE"
    var question: Question!
    init(question: Question){
        self.question = question
    }
    init(_ standardAction: StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: DeleteFaqAction.type, payload: [:], isTypedAction: true)
    }
}
