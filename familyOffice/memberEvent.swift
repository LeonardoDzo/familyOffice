//
//  memberEvent.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 08/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import RealmSwift

struct memberEvent {
    static let kId = "Id"
    static let kStatus = "status"
    static let kReminder = "reminder"
    var id: String!
    var status: String!
    var reminder: String!
    init(id:String, reminder: String, status: String) {
        self.id = id
        self.status = status
        self.reminder = reminder
    }
    init(snapshot: NSDictionary, id: String) {
        self.id = id
        self.status = service.UTILITY_SERVICE.exist(field: memberEvent.kStatus, dictionary: snapshot)
        self.reminder = service.UTILITY_SERVICE.exist(field: memberEvent.kReminder, dictionary: snapshot)
    }
    func toDictionary() -> NSDictionary {
        
        return[
                memberEvent.kStatus : self.status,
                memberEvent.kReminder : self.reminder
             ]
        
    }
    
    func statusImage() -> UIImage {
        var image : UIImage!
        
        switch self.status {
        case "Pendiente":
            image = #imageLiteral(resourceName: "pendiente")
            break
        case "Aceptada":
            image = #imageLiteral(resourceName: "Accept")
            break
        default:
            image = #imageLiteral(resourceName: "Cancel")
            break
        }
        return image
    }
}
@objcMembers
class memberEventEntity: Object, Codable, Serializable {

    var id: String = ""
    var status: String = "Pendiente"
    var reminder: Int = 0
    required convenience init(id:String, reminder: Int, status: String) {
        self.init()
        self.id = id
        self.status = status
        self.reminder = reminder
    }

    func statusImage() -> UIImage {
        var image : UIImage!
        
        switch self.status {
        case "Pendiente":
            image = #imageLiteral(resourceName: "pendiente")
            break
        case "Aceptada":
            image = #imageLiteral(resourceName: "Accept")
            break
        default:
            image = #imageLiteral(resourceName: "Cancel")
            break
        }
        return image
    }
}
