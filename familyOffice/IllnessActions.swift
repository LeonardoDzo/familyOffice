//
//  IllnessActions.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/20/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder

let illnessActionTypeMap: TypeMap = [
    InsertIllnessAction.type: InsertIllnessAction.self,
    UpdateIllnessAction.type: UpdateIllnessAction.self,
    DeleteIllnessAction.type: DeleteIllnessAction.self]

struct InsertIllnessAction: StandardActionConvertible {
    static let type = "ILLNESS_ACTION_INSERT"
    var illness: Illness!
    init(illness: Illness){
        self.illness = illness
    }
    init(_ standardAction: StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertIllnessAction.type, payload: [:], isTypedAction: true)
    }
}

struct UpdateIllnessAction: StandardActionConvertible {
    static let type = "ILLNESS_ACTION_UPDATE"
    var illness: Illness!
    init(illness: Illness){
        self.illness = illness
    }
    init(_ standardAction: StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: UpdateIllnessAction.type, payload: [:], isTypedAction: true)
    }
}

struct DeleteIllnessAction: StandardActionConvertible {
    static let type = "ILLNESS_ACTION_DELETE"
    var illness: Illness!
    init(illness: Illness){
        self.illness = illness
    }
    init(_ standardAction: StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: DeleteIllnessAction.type, payload: [:], isTypedAction: true)
    }
}
