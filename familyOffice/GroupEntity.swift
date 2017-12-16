//
//  GroupEntity.swift
//  familyOffice
//
//  Created by Nan Montaño on 12/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class GroupEntity: Object, Serializable {
    dynamic var id: String = ""
    dynamic var familyId: String = ""
    dynamic var title: String = ""
    dynamic var members = List<RealmString>()
    dynamic var coverPhoto: String = ""
    dynamic var messages = List<RealmString>()
    dynamic var lastMessage: String? = nil
    dynamic var createdAt: Date = Date()
    
    private enum CodingKeys: String, CodingKey {
        case id, familyId, title, coverPhoto, lastMessage, createdAt
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func toJSON() -> [String : Any]? {
        var membersDic = [String:Bool]()
        var msgsDic = [String:Bool]()
        members.forEach({ membersDic[$0.value] = true })
        messages.forEach({ msgsDic[$0.value] = true})
        var json = [
            "familyId": familyId,
            "title": title,
            "members": membersDic,
            "coverPhoto": coverPhoto,
            "messages": msgsDic,
            "createdAt": createdAt.toMillis()
            ] as [String : Any]
        if let lastMessage = self.lastMessage {
            json["lastMessage"] = lastMessage
        }
        return json
    }
}
