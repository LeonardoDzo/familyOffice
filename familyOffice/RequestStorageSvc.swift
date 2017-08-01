//
//  RequestStorageSvc.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Firebase
import Gzip
protocol RequestStorageSvc {

    func inserted(metadata: FIRStorageMetadata, data: Data) -> Void
    
}
extension RequestStorageSvc {

    
    func insert(_ ref: String, value: Any, callback: @escaping ((Any?) -> Void)) {
        var uploadData: Data = Data()
        var metadata = FIRStorageMetadata()
        if value is UIImage{
            metadata.contentType = "image/jpeg"
            let aux: Data = (value as! UIImage).resizeImage().jpeg(.high)!
            uploadData = try! aux.gzipped(level: .bestCompression)
        }
        if value is Data{
            if ref.contains("m4v"){
                metadata.contentType = "video/mp4"
            }
            uploadData = value as! Data
        }
        Constants.FirStorage.STORAGEREF.child(ref).put(uploadData, metadata: metadata) { metadata, error in
            if (error != nil) {
                print(error.debugDescription)
                callback(nil)
            } else {
                self.inserted(metadata: metadata!, data: uploadData)
                DispatchQueue.main.async {
                    callback(metadata!)
                }
                
            }
            
        }
    }
    func insertImageSmall(_ ref: String, value: Any, callback: @escaping ((Any?) -> Void)) {
        var uploadData: Data = Data()
        if value is UIImage{
            let aux: Data = (value as! UIImage).resizeImage().jpeg(.high)!
            uploadData = try! aux.gzipped(level: .bestCompression)
        }
        var metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        Constants.FirStorage.STORAGEREF.child(ref).put(uploadData, metadata: metadata) { metadata, error in
            if (error != nil) {
                print(error.debugDescription)
                callback(nil)
            } else {
                self.inserted(metadata: metadata!, data: uploadData)
                DispatchQueue.main.async {
                    callback(metadata!)
                }
                
            }
            
        }
    }
}
