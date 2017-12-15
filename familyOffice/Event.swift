//
//  DatesModel.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 23/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase

public enum EventAvailability : Int {
    
    
    case notSupported
    
    case busy
    
    case free
    
    case tentative
    
    case unavailable
}

public enum Priority: Int, Codable {
    case Baja,
    Media,
    Alta
}

public enum EventStatus : Int, Codable {
    
    
    case none
    
    case confirmed
    
    case tentative
    
    case canceled
}

@objc enum eventType: Int, GDL90_Enum, Codable, CustomStringConvertible  {

    case Default = 0, BirthDay, Meet
    
    var description: String {
        switch self {
        case .BirthDay:
            return "Cumpleaños"
        case .Meet:
            return "Reunion"
        default:
            return "Default"
        }
    }
}
