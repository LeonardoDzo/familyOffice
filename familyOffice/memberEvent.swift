//
//  memberEvent.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 08/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import RealmSwift


@objcMembers
class memberEventEntity: Object, Codable, Serializable {

    dynamic var userId: String! = ""
    dynamic var status: EventStatus! = .none
    dynamic var reminder: Int? = 0
    

    func statusImage() -> UIImage {
        var image : UIImage!
        
        switch self.status {
        case .none:
            image = #imageLiteral(resourceName: "pendiente")
            break
        case .confirmed:
            image = #imageLiteral(resourceName: "Accept")
            break
        default:
            image = #imageLiteral(resourceName: "Cancel")
            break
        }
        return image
    }
}
