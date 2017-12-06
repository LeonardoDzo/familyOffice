//
//  IllnessEntity.swift
//  familyOffice
//
//  Created by Nan Montaño on 30/nov/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class IllnessEntity : Object, Serializable {
    
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var family: String = ""
    dynamic var medicine: String = ""
    dynamic var dosage: String = ""
    dynamic var moreInfo: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

protocol IllnessBindable: AnyObject {
    var model: IllnessEntity! { get set }
    var nameLabel: UILabel! { get }
    var medicineLabel: UILabel! { get }
    var dosageLabel: UILabel! { get }
    var infoLabel: UILabel! { get }
}

extension IllnessBindable {
    var nameLabel: UILabel! { return nil }
    var medicineLabel: UILabel! { return nil }
    var dosageLabel: UILabel! { return nil }
    var infoLabel: UILabel! { return nil }
    
    func bind(model: IllnessEntity) {
        self.model = model
        bind()
    }
    
    func bind() {
        guard let illness = self.model else {
            return
        }
        if let nameLabel = self.nameLabel {
            nameLabel.text = illness.name
        }
        if let medicineLabel = self.medicineLabel {
            medicineLabel.text = illness.medicine
        }
        if let dosageLabel = self.dosageLabel {
            dosageLabel.text = illness.dosage
        }
        if let infoLabel = self.infoLabel {
            infoLabel.text = illness.moreInfo
        }
    }
}
