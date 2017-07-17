//
//  RequestStorageSvc.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Firebase
protocol RequestStorageSvc {

    func inserted(metadata: FIRStorageMetadata, data: Data) -> Void
    
}
extension RequestStorageSvc {

    
    func insert(_ ref: String, value: Any, callback: @escaping ((Any?) -> Void)) {
        
        if let uploadData = UIImagePNGRepresentation(value as! UIImage){
            _ = Constants.FirStorage.STORAGEREF.child(ref).put(uploadData, metadata: nil) { metadata, error in
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
}
