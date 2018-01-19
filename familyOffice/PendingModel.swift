//
//  PendingModel.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 16/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift

@objc enum PENDING_PRIORITY: Int, CustomStringConvertible {
    case High = 2
    case Normal = 1
    case Low = 0
    
    var description: String {
        switch self {
        case .High:
            return "Alta"
        case .Normal:
            return "Normal"
        case .Low:
            return "Baja"
        }
    }
    var color: UIColor! {
        switch self {
        case .Low:
            return #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        case .Normal:
            return #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        case .High:
            return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            
        }
    }
}
extension PENDING_PRIORITY : Codable {
    enum CodingKeys: Int, CodingKey {
        case High, Normal, Low
    }
}
@objcMembers
class PendingEntity: Object, Codable, Serializable {
    
    dynamic var id: String = ""
    dynamic var details: String = ""
    dynamic var title: String = ""
    dynamic var priority: PENDING_PRIORITY = .Normal
    dynamic var done: Bool = false
    dynamic var type : Int = 0
    dynamic var seen : Bool = false
    dynamic var boss : String = ""
    dynamic var assistantId: String = ""
    dynamic var created_at : Int = 0
    dynamic var updated_at : Int = 0
    private enum CodingKeys: String, CodingKey {
        case id,
        details,
        title,
        priority,
        done,
        type,
        seen,
        boss,
        assistantId,
        updated_at,
        created_at
    }
    override public static func primaryKey() -> String? {
        return "id"
    }
}


protocol PendingBindable: AnyObject, bind {
    var pending: PendingEntity! {get set}
    var titleLbl: UILabelX! {get}
    var createdAtLbl: UILabelX! {get}
    var updatedAtLbl: UILabelX! {get}
    var detailsTxtV : UITextView! {get}
    var priority: UIViewX! {get}
    var doneImg: UIImageViewX! {get}
}
extension PendingBindable {
    var titleLbl: UILabelX! {return nil}
    var detailsTxtV : UITextView! {return nil}
    var priority: UIViewX! {return nil}
    var doneImg: UIImageViewX! {return nil}
    var createdAtLbl: UILabelX! {return nil}
    var updatedAtLbl: UILabelX! {return nil}
    func bind(sender: Any?) {
        if sender is PendingEntity{
            self.pending = sender as! PendingEntity
            bind()
        }
    }
    func bind() -> Void {
        guard let pending = self.pending else {return}
        
        if let titleLbl = titleLbl {
            titleLbl.text = pending.title
        }
        if let updatedAtLbl = updatedAtLbl {
            updatedAtLbl.text = pending.updated_at.toDate().string(with: .MMMddHHmm)
        }
        if let createdAtLbl = createdAtLbl {
            createdAtLbl.text = pending.created_at.toDate().string(with: .MMMddHHmm)
        }
        if let detailsTxtV = detailsTxtV {
            detailsTxtV.text = pending.details
            detailsTxtV.isEditable = false
            detailsTxtV.isUserInteractionEnabled = false
        }
        if let priority = priority {
            priority.backgroundColor = self.pending.priority.color
        }
        if let doneImg = doneImg {
            doneImg.image = pending.done ? #imageLiteral(resourceName: "success").maskWithColor(color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))! : #imageLiteral(resourceName: "icons8-clock").maskWithColor(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))!
        }
        if let doneImg = doneImg {
            doneImg.image = pending.done ? #imageLiteral(resourceName: "success").maskWithColor(color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))! : #imageLiteral(resourceName: "icons8-clock").maskWithColor(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))!
        }
        
    }
    
}

extension Int {
    func toDate() -> Date {
        return Date(self)!
    }
}
