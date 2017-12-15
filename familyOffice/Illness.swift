//
//  Illness.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/19/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

struct Illness{
    static let illKey = "aidi"
    static let illNameKey = "nombre"
    static let illMedicineKey = "medicine"
    static let illDosageKey = "dosis"
    static let illMoreInfoKey = "masinfo"
    
    var id: String?
    var name: String!
    var medicine: String!
    var dosage: String!
    var moreInfo: String!
    
    init(name: String, medicine: String, dosage: String, moreInfo: String){
        self.name = name
        self.medicine = medicine
        self.dosage = dosage
        self.moreInfo = moreInfo
        self.id = Constants.FirDatabase.REF.child("illnesses").childByAutoId().key
    }
    
    init(dic: NSDictionary){
        
        
    }
    
    init(snapshot: DataSnapshot){
        let dic = snapshot.value as! NSDictionary
        self.id  = snapshot.key
        self.name = service.UTILITY_SERVICE.exist(field: Illness.illNameKey, dictionary: dic)
        self.medicine = service.UTILITY_SERVICE.exist(field: Illness.illMedicineKey, dictionary: dic)
        self.dosage = service.UTILITY_SERVICE.exist(field: Illness.illDosageKey, dictionary: dic)
        self.moreInfo = service.UTILITY_SERVICE.exist(field: Illness.illMoreInfoKey, dictionary: dic)
    }
    
    func toDictionary() -> NSDictionary {
        return [
            Illness.illNameKey: self.name,
            Illness.illMedicineKey: self.medicine,
            Illness.illDosageKey: self.dosage,
            Illness.illMoreInfoKey: self.moreInfo
        ]
    }
    
}
