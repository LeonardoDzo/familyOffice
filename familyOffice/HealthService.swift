//
//  HealthService.swift
//  familyOffice
//
//  Created by Nan Montaño on 29/mar/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

class HealthService {
    
    private init() {}
    
    static private let instance = HealthService()
    
    public static func Instance() -> HealthService { return instance }
        
}
