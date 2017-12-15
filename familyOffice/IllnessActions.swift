//
//  IllnessActions.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/20/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct InsertIllnessAction: Action {
    var illness: Illness!
    init(illness: Illness){
        self.illness = illness
    }
}

struct UpdateIllnessAction: Action {
    var illness: Illness!
    init(illness: Illness){
        self.illness = illness
    }
}

struct DeleteIllnessAction: Action {
    var illness: Illness!
    init(illness: Illness){
        self.illness = illness
    }
}
