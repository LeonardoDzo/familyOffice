//
//  MedicineEntity.swift
//  familyOffice
//
//  Created by Nan Montaño on 30/nov/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class MedicineEntity : Object, Serializable {
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var indications: String = ""
    dynamic var dosage: String = ""
    dynamic var restrictions: String = ""
    dynamic var moreInfo: String = ""
}

protocol MedicineBindable: AnyObject {
    var model: MedicineEntity! { get set }
    var nameLabel: UILabel! { get }
    var indicationsLabel: UILabel! { get }
    var dosageLabel: UILabel! { get }
    var restrictionsLabel: UILabel! { get }
    var infoLabel: UILabel! { get }
}

extension MedicineBindable {
    var nameLabel: UILabel! { return nil }
    var indicationsLabel: UILabel! { return nil }
    var dosageLabel: UILabel! { return nil }
    var restrictionsLabel: UILabel! { return nil }
    var infoLabel: UILabel! { return nil }
    
    func bind(medicine: MedicineEntity) {
        self.model = medicine
        bind()
    }
    
    func bind() {
        guard let medicine = self.model else {
            return
        }
        if let nameLabel = self.nameLabel {
            nameLabel.text = medicine.name
        }
        if let indicationsLabel = self.indicationsLabel {
            indicationsLabel.text = medicine.indications
        }
        if let dosageLabel = self.dosageLabel {
            dosageLabel.text = medicine.dosage
        }
        if let restrictionsLabel = self.restrictionsLabel {
            restrictionsLabel.text = medicine.restrictions
        }
        if let infoLabel = self.infoLabel {
            infoLabel.text = medicine.moreInfo
        }
    }
    
}
