//
//  Notification.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 15/02/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase
enum Notification_Type: Int {
    case event=1,goal,gallery,safeb,contacts,firstAidKit,properties,heal,insurance,budget,todolist,faqs
}
struct NotificationModel {
    typealias not = NotificationModel
    static let kNotificationIdkey = "id"
    static let kNotificationTitlekey = "title"
    static let kNotificationDatekey = "timestamp"
    static let kNotificationPhotokey = "photo"
    static let kNotificationSeenkey = "seen"
    static let kNotificationType = "type"
    
    let id: String!
    let title: String!
    let timestamp: Int!
    var seen: Bool!
    var photoURL: String!
    var type: Notification_Type!

    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! NSDictionary
        self.id = snapshot.key
        self.title = snapshotValue.exist(field: not.kNotificationTitlekey)
        self.timestamp = snapshotValue.exist(field: not.kNotificationDatekey)
        self.seen = snapshotValue.object(forKey: "seen") as! Bool
        self.photoURL = snapshotValue.exist(field: not.kNotificationPhotokey)
        if let type : Int = snapshotValue.exist(field: not.kNotificationType) {
            self.type = Notification_Type(rawValue: type)
        }else{
            let randomNum: UInt32 = arc4random_uniform(8) + 1
            self.type = Notification_Type(rawValue: Int(randomNum))
        }
        
    }
    func toDictionary() -> NSDictionary {
        return [
            NotificationModel.kNotificationDatekey : self.timestamp,
            NotificationModel.kNotificationTitlekey : self.title,
            NotificationModel.kNotificationPhotokey : self.photoURL,
            NotificationModel.kNotificationSeenkey : self.seen
        ]
    }

}
extension NotificationModel: Equatable {
    /// Equality check ignoring the `familyId`.
    func hasEqualContent(_ other: NotificationModel) -> Bool {
        return other.id == id
    }
}

func ==(lhs: NotificationModel, rhs: NotificationModel) -> Bool {
    return lhs.id == rhs.id
}

protocol NotificationBindible: AnyObject {
    var notification : NotificationModel! {get set}
    var titleLbl: UILabel! {get}
    var dateLbl: UILabel! {get}
    var img: CustomUIImageView! {get}
    var typeImg: CustomUIImageView! {get}
}
extension NotificationBindible {
    var titleLbl: UILabel! {return nil}
    var dateLbl: UILabel! {return nil}
    var img: CustomUIImageView! {return nil}
    var typeImg: CustomUIImageView! {return nil}
    
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
        if let dateLbl = self.dateLbl {
            let date = Date(timeIntervalSince1970: TimeInterval(notification.timestamp/1000))
            dateLbl.text = date.string(with: .dayMonthAndYear2)
        }
        if let photo = self.img {
            if  !notification.photoURL.isEmpty {
                photo.loadImage(urlString: notification.photoURL)
            }else{
                photo.image = #imageLiteral(resourceName: "logo")
            }
            
        }
    }
}
