//
//  SafeBoxActions.swift
//  familyOffice
//
//  Created by Developer on 8/16/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder

let safeBoxActionTypeMap: TypeMap = [
    InsertSafeBoxFileAction.type:InsertSafeBoxFileAction.self,
    UpdateSafeBoxFileAction.type:UpdateSafeBoxFileAction.self,
    DeleteSafeBoxFileAction.type:DeleteSafeBoxFileAction.self]

struct InsertSafeBoxFileAction: StandardActionConvertible{
    static let type = "SAFEBOX_ACTION_INSERT"
    var safeBoxFile: SafeBoxFile!
    init(item: SafeBoxFile){
        self.safeBoxFile = item
    }
    init(_ standardAction: StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertSafeBoxFileAction.type, payload: [:], isTypedAction: true)
    }
}

struct UpdateSafeBoxFileAction: StandardActionConvertible{
    static let type = "SAFEBOX_ACTION_UPDATE"
    var safeBoxFile: SafeBoxFile!
    init(item: SafeBoxFile){
        self.safeBoxFile = item
    }
    init (_ standarAction:StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: UpdateSafeBoxFileAction.type, payload: [:], isTypedAction: true)
    }
}

struct DeleteSafeBoxFileAction: StandardActionConvertible{
    static let type = "SAFEBOX_ACTION_DELETE"
    var safeBoxFile: SafeBoxFile!
    init(item: SafeBoxFile){
        self.safeBoxFile = item
    }
    init (_ standarAction:StandardAction){
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: DeleteSafeBoxFileAction.type, payload: [:], isTypedAction: true)
    }
}
