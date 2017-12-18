//
//  Message.swift
//  familyOffice
//
//  Created by Nan Montaño on 12/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift

enum MessageStatus: Int {
    case Pending = 0, Sent = 1, Seen = 2, Failed = -1
}

@objcMembers
class MessageEntity: Object, Serializable {
    
    dynamic var id: String = ""
    dynamic var groupId: String = ""
    dynamic var remittent: String = ""
    dynamic var receiver: String = ""
    dynamic var text: String = ""
    dynamic var type: String = ""
    dynamic var timestamp: Date = Date()
    dynamic var status: Int = MessageStatus.Pending.rawValue
    dynamic var parent: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func toJSON() -> [String : Any]? {
        var json = [
            "groupId": groupId,
            "remittent": remittent,
            "receiver": receiver,
            "text": text,
            "type": type,
            "timestamp": timestamp.toMillis(),
            "status": status
        ] as [String : Any]
        if let parent = self.parent { json["parent"] = parent }
        return json
    }
}
