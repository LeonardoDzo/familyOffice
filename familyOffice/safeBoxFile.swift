//
//  safeBoxFile.swift
//  familyOffice
//
//  Created by Developer on 8/15/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

struct SafeBoxFile{
    static let fKey = "id"
    static let fFilename = "filename"
    static let fdownloadUrl = "downloadUrl"
    static let fParent = "parent"
    
    var id: String?
    var filename: String!
    var downloadUrl: String!
    var parent: String!
    
    init(filename: String, downloadUrl: String){
        self.filename = filename
        self.downloadUrl = downloadUrl
        self.parent = "root"
        self.id = Constants.FirDatabase.REF.childByAutoId().key
    }
    
    init(filename: String, downloadUrl: String, parent: String){
        self.filename = filename
        self.downloadUrl = downloadUrl
        self.parent = parent
        self.id = Constants.FirDatabase.REF.childByAutoId().key
    }
    
    init(snapshot: FIRDataSnapshot){
        let dic = snapshot.value as! NSDictionary
        self.id = snapshot.key
        self.filename = service.UTILITY_SERVICE.exist(field: SafeBoxFile.fFilename, dictionary: dic)
        self.downloadUrl = service.UTILITY_SERVICE.exist(field: SafeBoxFile.fdownloadUrl, dictionary: dic)
        self.parent = service.UTILITY_SERVICE.exist(field: SafeBoxFile.fParent, dictionary: dic)
    }
    
    func toDictionary() -> NSDictionary {
        return[
            SafeBoxFile.fFilename: self.filename,
            SafeBoxFile.fdownloadUrl: self.downloadUrl ?? "",
            SafeBoxFile.fParent: self.parent
        ]
    }
}
