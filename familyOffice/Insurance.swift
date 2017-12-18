//
//  Insurance.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazar on 12/16/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

struct Insurance{
    static let fKey = "id"
    static let fName = "name"
    static let fType = "type"
    static let fTelephone = "telephone"
    static let fPolicy = "policy"
    static let fDownloadUrl = "downloadUrl"
    
    var id: String?
    var name: String!
    var type: String!
    var telephone: String!
    var downloadUrl: String?
    var policy: String!
    
    init(name: String, type: String, telephone:String, policy: String, downloadUrl: String){
        self.name = name
        self.telephone = telephone
        self.policy = policy
        self.type = type
        self.downloadUrl = downloadUrl
        self.id = Constants.FirDatabase.REF.childByAutoId().key
    }
    
    init(snapshot: DataSnapshot){
        let dic = snapshot.value as! NSDictionary
        self.id = snapshot.key
        self.name = service.UTILITY_SERVICE.exist(field: Insurance.fName, dictionary: dic)
        self.type = service.UTILITY_SERVICE.exist(field: Insurance.fType, dictionary: dic)
        self.telephone = service.UTILITY_SERVICE.exist(field: Insurance.fTelephone, dictionary: dic)
        self.downloadUrl = service.UTILITY_SERVICE.exist(field: Insurance.fDownloadUrl, dictionary: dic)
        self.policy = service.UTILITY_SERVICE.exist(field: Insurance.fPolicy, dictionary: dic)
    }
    
    func toDictionary() -> NSDictionary {
        return[
            SafeBoxFile.fKey: self.id,
            Insurance.fName: self.name,
            Insurance.fTelephone: self.telephone,
            Insurance.fPolicy: self.policy,
            Insurance.fDownloadUrl: self.downloadUrl ?? "",
            Insurance.fType: self.type
        ]
    }
}
