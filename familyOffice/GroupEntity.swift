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
    dynamic var isGroup = true
    
    private enum CodingKeys: String, CodingKey {
        case id, familyId, title, coverPhoto, lastMessage, createdAt, isGroup
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
            "createdAt": createdAt.toMillis(),
            "isGroup" : isGroup
            ] as [String : Any]
        if let lastMessage = self.lastMessage {
            json["lastMessage"] = lastMessage
        }
        return json
    }
}
protocol GroupBindible: AnyObject, bind {
    var group: GroupEntity! {get set}
    var groupImg: UIImageView! {get}
    var groupName: UILabel! {get}
    var lastMsg: UILabel! {get}
    var msgTime: UILabel! {get}
    
}
extension GroupBindible {
    var groupImg: UIImageView! {return nil}
    var groupName: UILabel! {return nil}
    var lastMsg: UILabel! {return nil}
    var msgTime: UILabel! {return nil}
    
    func bind(sender: Any?) {
        if sender is GroupEntity {
            self.group = sender as! GroupEntity
            self.bind()
        }
    }
    
    func bind() -> Void {
        guard let group = self.group else { return  }
        let user : UserEntity! = {
            if !group.isGroup {
                if let mid = group.members.first(where: {$0.value != getUser()?.id})?.value {
                    if let user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: mid) {
                        return user
                    }else{
                        store.dispatch(UserS(.getbyId(uid: mid)))
                    }
                }
            }
            return nil
        }()
        
        if let groupImg = groupImg {
            groupImg.image = #imageLiteral(resourceName: "background_family")
            if !group.coverPhoto.isEmpty {
                groupImg.loadImage(urlString: group.coverPhoto)
            } else if !group.isGroup {
                if user != nil {
                    groupImg.loadImage(urlString: user.photoURL)
                }
            }
            
        }
        if let groupName = groupName {
            groupName.text = "Cargando..."
            if group.isGroup {
                groupName.text = group.title
            }else if !group.isGroup{
                if user != nil {
                     groupName.text = user.name
                }
            }
        }
        if let lastMsg = lastMsg, let msgTime = msgTime {
            guard let msgId = group.lastMessage else {
                lastMsg.text = ""
                msgTime.text = ""
                return
            }
            if let msg = rManager.realm.objects(MessageEntity.self).filter("id = '\(msgId)'").first {
                lastMsg.text = msg.text
                msgTime.text = msg.timestamp.string(with: DateFormatter.hourAndMin)
            }else{
                store.dispatch(getMessageAction(messageId: msgId, uuid: msgId))

            }
        }
    }
}

