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

@objc enum Notification_Type: Int{
    case event,
    goal,
    gallery,
    safeb,
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
        default:
            return ""
        }
    }
    var img : UIImage {
        switch self {
        case .event:
            return #imageLiteral(resourceName: "Calendar").maskWithColor(color: self.color)!
        case .family:
            return #imageLiteral(resourceName: "familyImage").maskWithColor(color: self.color)!
        default:
            return #imageLiteral(resourceName: "icons8-jingle_bell")
        }
    }
    
    var color : UIColor {
        switch self {
        case .event:
            return UIColor.yellow
        case .family:
            return UIColor.black
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
    
    func getType(_ key: String) -> Notification_Type {
        switch key {
        case "event":
            return .event
        case  "family":
            return .family
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
    var img: CustomUIImageView! {get}
    var typeImg: UIImageViewX! {get}
}
extension NotificationBindible {
    var titleLbl: UILabel! {return nil}
    var dateLbl: UILabel! {return nil}
    var img: CustomUIImageView! {return nil}
    var typeImg: CustomUIImageView! {return nil}
    var bodyLbl: UILabel! {return nil}
    
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
            titleLbl.textColor = notification.type.color
        }
        if let bodyLbl = self.bodyLbl {
            bodyLbl.text = notification.body
            bodyLbl.textColor = notification.type.color
        }
        if let dateLbl = self.dateLbl {
            let date = Date(timeIntervalSince1970: TimeInterval(notification.timestamp/1000))
            dateLbl.text = date.string(with: .dayMonthAndYear2)
        }
        if let typeImg = self.typeImg {
            typeImg.image = notification.type.img
        }
    }
}
