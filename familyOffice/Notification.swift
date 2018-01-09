//
//  Notification.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 15/02/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase
import RealmSwift
import UserNotifications

@objc enum Notification_Type: Int{
    case event,
    goal,
    gallery,
    safebox,
    chat,
    contacts,
    firstAidKit,
    properties,
    heal,
    insurance,
    budget,
    todolist,
    family,
    faqs,
    none
    
    var description : String {
        switch self {
        case .event:
            return "event"
        case .family:
            return "family"
        case .chat:
            return "chat"
        case .safebox:
            return "safebox"
        default:
            return ""
        }
    }
    var img : UIImage {
        switch self {
        case .event:
            return #imageLiteral(resourceName: "Calendar").maskWithColor(color: self.color)!
        case .family:
            return #imageLiteral(resourceName: "members").maskWithColor(color: self.color)!
        case .chat:
            return #imageLiteral(resourceName: "chat").maskWithColor(color: self.color)!
        case .safebox:
            return #imageLiteral(resourceName: "safeBox").maskWithColor(color: self.color)!
        default:
            return #imageLiteral(resourceName: "icons8-jingle_bell")
        }
    }
    
    var color : UIColor {
        switch self {
        case .event:
            return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        case .chat:
            return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        case .safebox:
            return #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        default:
            return UIColor.black
            
        }
    }

}
@objcMembers
class NotificationModel : Object {
    typealias not = NotificationModel
    
    dynamic var id: String = ""
    dynamic var title: String = ""
    dynamic var timestamp: Int = 0
    dynamic var value: String = ""
    dynamic var type: Notification_Type = .none
    dynamic var body = ""
    dynamic var seen = false
    dynamic var lastupdated = 0
    convenience required init(snapshot: DataSnapshot) {
        self.init()
        let snapshotValue = snapshot.value as! NSDictionary
        self.id = snapshot.key
        if let notification = snapshotValue["notification"] as? NSDictionary {
            self.title = notification.exist(field: "title")
            self.body = notification.exist(field: "body")
        }
      
        if let data = snapshotValue["data"] as? NSDictionary {
            data.forEach({ (key, value) in
                if let k = key as? String, k != "user", value is String {
                    self.type = getType(k)
                    self.value = value as! String
                }
            })
        }
        
    }
    convenience required init(notifiaction: UNNotification) {
        self.init()
        let content = notifiaction.request.content
        
        self.id = notifiaction.request.identifier
        
        
        self.title = content.title
        self.body = content.body
        self.timestamp = notifiaction.date.toMillis()
        content.userInfo.forEach({ (key, value) in
            if let k = key as? String, k != "user", value is String {
                let v = getType(k)
                if case Notification_Type.none = v {
                }else{
                    
                    
                    self.type = v
                    self.value = value as! String
                }
            }
        })
    }
    convenience required init(dic: [AnyHashable: Any]) {
        self.init()
        if let aps = dic["aps"] as? NSDictionary, let content =  aps["alert"] as? NSDictionary{
            if let id = dic["gcm.message_id"] as? String {
                self.id =  id
            }
            
            
            if let title = content["title"] as? String {
                self.title = title
            }
            if let body = content["body"] as? String {
                self.body = body
            }
            self.timestamp = Date().toMillis()
            dic.forEach({ (key, value) in
                if let k = key as? String, k != "alert", value is String {
                    let v = getType(k)
                    if case Notification_Type.none = v {
                    }else{
                        self.type = v
                        self.value = value as! String
                    }
                }
            })
        }
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    func getType(_ key: String) -> Notification_Type {
        switch key {
        case "event":
            return .event
        case  "family":
            return .family
        case "chat":
            return .chat
        default:
            return .none
        }
    }
    
    
    
}

protocol NotificationBindible: AnyObject {
    var notification : NotificationModel! {get set}
    var titleLbl: UILabel! {get}
    var bodyLbl: UILabel! {get}
    var dateLbl: UILabel! {get}
    var bodyTxtV: UITextView! {get}
    var img: CustomUIImageView! {get}
    var typeImg: UIImageViewX! {get}
}
extension NotificationBindible {
    var titleLbl: UILabel! {return nil}
    var dateLbl: UILabel! {return nil}
    var img: CustomUIImageView! {return nil}
    var typeImg: CustomUIImageView! {return nil}
    var bodyLbl: UILabel! {return nil}
    var bodyTxtV: UITextView! {return nil}
    func bind(_ not: NotificationModel) -> Void {
        self.notification = not
        bind()
    }
    func bind() -> Void {
        guard let notification = self.notification else {
            return
        }
        if let titleLbl = self.titleLbl {
            titleLbl.text = notification.title
        }
        if let bodyLbl = self.bodyLbl {
            bodyLbl.text = notification.body
        }
        if let bodyTxtV = self.bodyTxtV {
            bodyTxtV.text = notification.body
        }
        if let dateLbl = self.dateLbl {
            if let date = Date(notification.timestamp) {
                if date.isToday() {
                    dateLbl.text = date.string(with: .hourAndMin)
                }else if date.isYesterday() {
                    dateLbl.text = "Ayer"
                }else{
                    dateLbl.text = date.string(with: .ddMMMyyyy)
                }
            }
            
            
        }
        
        if let typeImg = self.typeImg {
            typeImg.image = notification.type.img
        }
    }
}
