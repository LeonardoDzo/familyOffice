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
    
    var id: String?
    var filename: String!
    var downloadUrl: String!
    
    init(filename: String, downloadUrl: String){
        self.filename = filename
        self.downloadUrl = downloadUrl
        self.id = Constants.FirDatabase.REF.childByAutoId().key
    }
    
    init(snapshot: FIRDataSnapshot){
        let dic = snapshot.value as! NSDictionary
        self.id = snapshot.key
        self.filename = service.UTILITY_SERVICE.exist(field: SafeBoxFile.fFilename, dictionary: dic)
        self.downloadUrl = service.UTILITY_SERVICE.exist(field: SafeBoxFile.fdownloadUrl, dictionary: dic)
    }
    
    func toDictionary() -> NSDictionary {
        return[
            SafeBoxFile.fFilename: self.filename,
            SafeBoxFile.fdownloadUrl: self.downloadUrl ?? ""
        ]
    }
}
