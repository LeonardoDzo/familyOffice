//
//  SafeBoxActions.swift
//  familyOffice
//
//  Created by Developer on 8/16/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct InsertSafeBoxFileAction: Action{
    var safeBoxFile: SafeBoxFile!
    init(item: SafeBoxFile){
        self.safeBoxFile = item
    }
}

struct UpdateSafeBoxFileAction: Action{
    var safeBoxFile: SafeBoxFile!
    init(item: SafeBoxFile){
        self.safeBoxFile = item
    }
}

struct DeleteSafeBoxFileAction: Action{
    var safeBoxFile: SafeBoxFile!
    init(item: SafeBoxFile){
        self.safeBoxFile = item
    }
}
