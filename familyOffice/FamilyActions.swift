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
import FirebaseAuth
import UIKit

struct InsertFamilyAction: Action {
    var family: Family!
    var famImage: UIImage!
    init(family: Family, img: UIImage? = nil) {
        self.family = family
        self.famImage = img
    }
   
}
struct UpdateFamilyAction: Action {
    var family: Family!
    var famImage: UIImage!
    init(family: Family, img: UIImage? = nil) {
        self.family = family
        self.famImage = img
    }

}

struct DeleteFamilyAction: Action {
    var fid: String!
    init(fid: String) {
        self.fid = fid
    }
}



