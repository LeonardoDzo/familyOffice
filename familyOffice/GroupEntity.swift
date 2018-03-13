//
//  GroupEntity.swift
//  familyOffice
//
//  Created by Nan Montaño on 12/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseDatabase

@objcMembers
class TimestampEntity: Object, Serializable {
    dynamic var id: String = ""
    dynamic var time: Date = Date()
}

@objcMembers
class GroupEntity: Object, Serializable {
    dynamic var id: String = ""
    dynamic var familyId: String = ""
    dynamic var title: String = ""
    dynamic var members = List<TimestampEntity>()
    dynamic var coverPhoto: String = ""
    dynamic var messages = List<TimestampEntity>()
    dynamic var lastMessage: String? = nil
    dynamic var createdAt: Date = Date()
    dynamic var isGroup = true
    
    private enum CodingKeys: String, CodingKey {
        case id, familyId, title, coverPhoto, lastMessage, createdAt, isGroup
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    class func fromJSON(key: String, json: NSDictionary) -> GroupEntity {
        json.setValue(key, forKey: "id")
        let members = json["members"] as? NSDictionary  ?? [:]
        var membersR = [NSDictionary]()
        members.forEach({ (key, time) in
            membersR.append(["id": key, "time": Date(time as? Int ?? 1)!])
        })
        json.setValue(membersR, forKey: "members")
        let messages = json["messages"] as? NSDictionary ?? [:]
        var messagesR = [NSDictionary]()
        messages.forEach { (key, time) in
            messagesR.append(["id": key, "time": Date(time as? Int ?? 1)!])
        }
        json.setValue(messagesR, forKey: "messages")
        let createdAt = json["createdAt"] as? Int ?? 0
        json.setValue(Date(createdAt), forKey: "createdAt")
        return GroupEntity(value: json)
    }
    
    func toJSON() -> [String : Any]? {
        var membersDic = [String:Int]()
        var msgsDic = [String:Int]()
        members.forEach({ membersDic[$0.id] = $0.time.toMillis() })
        messages.forEach({ msgsDic[$0.id] = $0.time.toMillis() })
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
    
    func unseen(forUser user: String) -> Int {
        guard let member = members.first(where: { $0.id == user }) else {
            return -1
        }
        let predicate = NSPredicate(format: "time > %@", member.time as CVarArg)
        return messages.filter(predicate).count
    }
}
protocol GroupBindible: AnyObject, bind {
    var group: GroupEntity! {get set}
    var groupImg: UIImageViewX! {get}
    var groupName: UILabel! {get}
    var lastMsg: UILabel! {get}
    var msgTime: UILabel! {get}
    var unseen: UILabel! { get }
    var famName: UILabel! { get }
}
extension GroupBindible {
    var groupImg: UIImageViewX! {return nil}
    var groupName: UILabel! {return nil}
    var lastMsg: UILabel! {return nil}
    var msgTime: UILabel! {return nil}
    var unseen: UILabel! { return nil }
    var famName: UILabel! { return nil }
    
    func bind(sender: Any?) {
        if sender is GroupEntity {
            self.group = sender as! GroupEntity
            self.bind()
        }
    }
    
    func bind() -> Void {
        guard let group = self.group else { return  }
        let me = getUser()!
        let user : UserEntity! = {
            if !group.isGroup {
                if let mid = group.members.first(where: {$0.id != getUser()?.id})?.id {
                    if let user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: mid) {
                        return user
                    }else{
                        store.dispatch(UserS(.getbyId(uid: mid, assistant: false)))
                       
                    }
                }
            }
            return nil
        }()
        let assistant: AssistantEntity! = {
            if let mid = group.members.first(where: {$0.id != getUser()?.id})?.id {
                return rManager.realm.object(ofType: AssistantEntity.self, forPrimaryKey: mid)
            }
            return nil
        }()
        
        if let groupImg = groupImg {
            groupImg.image = #imageLiteral(resourceName: "background_family")
            if !group.coverPhoto.isEmpty {
                groupImg.loadImage(urlString: group.coverPhoto)
            } else if !group.isGroup {
                if user != nil && !user.photoURL.isEmpty {
                    groupImg.loadImage(urlString: user.photoURL)
                }else if assistant != nil && !(assistant?.photoURL.isEmpty)! {
                    groupImg.loadImage(urlString: assistant!.photoURL)
                }
                else {
                    groupImg.image = #imageLiteral(resourceName: "user-default")
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
                }else if assistant != nil {
                    groupName.text = "\((assistant?.name)!) (Asistente)"
                }
            }
        }
        if let lastMsg = lastMsg, let msgTime = msgTime {
            lastMsg.text = ""
            msgTime.text = ""
            if let msgId = group.lastMessage {
                if let msg = rManager.realm.objects(MessageEntity.self).filter("id = '\(msgId)'").first {
                    if let usr = rManager.realm.objects(UserEntity.self).filter("id = '\(msg.remittent)'").first {
                        lastMsg.text = "\(usr.id == me.id ? "Tu" : usr.name): \(msg.text)"
                        if msg.timestamp.isToday() {
                            msgTime.text = msg.timestamp.string(with: DateFormatter.hourAndMin)
                        } else if msg.timestamp.isYesterday() {
                            msgTime.text = "AYER"
                        } else {
                            msgTime.text = msg.timestamp.string(with: DateFormatter.ddMMMyyyy)
                        }
                    } else {
                        store.dispatch(UserS(.getbyId(uid: msg.remittent, assistant: false)))
                    }
                }else{
                    store.dispatch(getMessageAction(messageId: msgId, uuid: msgId))
                }
            }
        }
        if let unseen = unseen {
            let count = group.unseen(forUser: me.id)
            if count > 0 {
                unseen.alpha = 1
                unseen.text = "\(count)"
            } else {
                unseen.alpha = 0
            }
        }
        if let famName = famName {
            if let fam = rManager.realm.objects(FamilyEntity.self).first(where: { $0.id == group.familyId }) {
                famName.text = fam.name
            }
        }
    }
}

