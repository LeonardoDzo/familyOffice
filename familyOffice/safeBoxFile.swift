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
    static let fThumbnail = "thumbnail"
    static let fParent = "parent"
    
    var id: String?
    var filename: String!
    var downloadUrl: String!
    var thumbnail: String?
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
    
    init(filename: String, downloadUrl: String,thumbnail:String, parent: String){
        self.filename = filename
        self.downloadUrl = downloadUrl
        self.parent = parent
        self.thumbnail = thumbnail
        self.id = Constants.FirDatabase.REF.childByAutoId().key
    }
    
    init(snapshot: DataSnapshot){
        let dic = snapshot.value as! NSDictionary
        self.id = snapshot.key
        self.filename = service.UTILITY_SERVICE.exist(field: SafeBoxFile.fFilename, dictionary: dic)
        self.downloadUrl = service.UTILITY_SERVICE.exist(field: SafeBoxFile.fdownloadUrl, dictionary: dic)
        self.thumbnail = service.UTILITY_SERVICE.exist(field: SafeBoxFile.fThumbnail, dictionary: dic)
        self.parent = service.UTILITY_SERVICE.exist(field: SafeBoxFile.fParent, dictionary: dic)
    }
    
    func toDictionary() -> NSDictionary {
        return[
            SafeBoxFile.fFilename: self.filename,
            SafeBoxFile.fdownloadUrl: self.downloadUrl ?? "",
            SafeBoxFile.fThumbnail:self.thumbnail ?? "",
            SafeBoxFile.fParent: self.parent
        ]
    }
}
