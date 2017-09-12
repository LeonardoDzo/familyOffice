//
//  Medicine.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/19/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

struct Medicine{
    static let medKey = "id"
    static let medNameKey = "name"
    static let medIndicationsKey = "indications"
    static let medDosageKey = "dosage"
    static let medRestrictionsKey = "restrictions"
    static let medMoreInfoKey = "moreInfo"
    
    var id: String?
    var name: String!
    var indications: String!
    var dosage: String!
    var restrictions: String!
    var moreInfo: String!
    
    init(name: String, indications: String, dosage: String, restrictions: String, moreInfo: String){
        self.name = name
        self.indications = indications
        self.dosage = dosage
        self.restrictions = restrictions
        self.moreInfo = moreInfo
        self.id = Constants.FirDatabase.REF.childByAutoId().key
    }
    
    init(dic: NSDictionary){
        
        
    }
    
    init(snapshot: DataSnapshot){
        let dic = snapshot.value as! NSDictionary
        self.id  = snapshot.key
        self.name = service.UTILITY_SERVICE.exist(field: Medicine.medNameKey, dictionary: dic)
        self.indications = service.UTILITY_SERVICE.exist(field: Medicine.medIndicationsKey, dictionary: dic)
        self.restrictions = service.UTILITY_SERVICE.exist(field: Medicine.medRestrictionsKey, dictionary: dic)
        self.dosage = service.UTILITY_SERVICE.exist(field: Medicine.medDosageKey, dictionary: dic)
        self.moreInfo = service.UTILITY_SERVICE.exist(field: Medicine.medMoreInfoKey, dictionary: dic)
    }
    
    func toDictionary() -> NSDictionary {
        return [
            Medicine.medNameKey: self.name,
            Medicine.medIndicationsKey: self.indications,
            Medicine.medRestrictionsKey: self.restrictions,
            Medicine.medDosageKey: self.dosage,
            Medicine.medMoreInfoKey: self.moreInfo
        ]
    }
    
}
