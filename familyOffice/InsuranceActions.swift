//
//  InsuranceActions.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazat on 12/18/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift


struct InsertInsuranceAction: Action {
    
    var insurance: Insurance!
    init(item: Insurance){
        self.insurance = item
    }
    
    
}

struct UpdateInsuranceAction: Action {
    
    var insurance: Insurance!
    init(item: Insurance){
        self.insurance = item
    }
    
    
}

struct DeleteInsuranceAction: Action{
    var insurance: Insurance!
    init(item: Insurance){
        self.insurance = item
    }
}
