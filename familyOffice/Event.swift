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

@objc public enum EventStatus : Int, Codable, CustomStringConvertible {
    
    
    
    
    case none
    
    case confirmed
    
    case tentative
    
    case canceled
    
    public var description: String {
        switch self {
        case .canceled:
            return "canceled"
        case .confirmed:
            return "confirmed"
        case .tentative:
            return "tentative"
        default:
            return "none"
        }
    }
    public var color: UIColor {
        switch self {
        case .canceled:
            return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        case .confirmed:
            return #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        case .tentative:
            return #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        default:
            return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
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
