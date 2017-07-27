//
//  FamilyActions.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 19/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

//
//  UserActions.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder
import FirebaseAuth
import UIKit
let familyActionTypeMap: TypeMap = [InsertFamilyAction.type: InsertFamilyAction.self,
                                    DeleteFamilyAction.type: DeleteFamilyAction.self,
                                    UpdateFamilyAction.type: UpdateFamilyAction.self]

struct InsertFamilyAction: StandardActionConvertible {
    static let type = "FAMILY_ACTION_INSERT"
    var family: Family!
    var famImage: UIImage!
    init(family: Family, img: UIImage? = nil) {
        self.family = family
        self.famImage = img
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertFamilyAction.type, payload: [:], isTypedAction: true)
    }
}
struct UpdateFamilyAction: StandardActionConvertible {
    static let type = "FAMILY_ACTION_UPDATE"
    var family: Family!
    var famImage: UIImage!
    init(family: Family, img: UIImage? = nil) {
        self.family = family
        self.famImage = img
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: UpdateFamilyAction.type, payload: [:], isTypedAction: true)
    }
}

struct DeleteFamilyAction: StandardActionConvertible {
    static let type = "FAMILY_ACTION_DELETE"
    var fid: String!
    init(fid: String) {
        self.fid = fid
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: DeleteFamilyAction.type, payload: [:], isTypedAction: true)
    }
}



