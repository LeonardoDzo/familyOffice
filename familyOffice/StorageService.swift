//
//  storageService.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 02/02/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import Gzip
class StorageService  {
    public var storage : NSMutableDictionary = [:]
    
    private init() {
    }
    public static func Instance() -> StorageService {
        return instance
    }
    private static let instance : StorageService = StorageService()
    
    func save(url: String, data: Data?) -> Void {
        if(data != nil){
            self.storage.setValue(data, forKey: url)
        }else{
            URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {(data, response, error) in
                if error != nil {                    print(error?.localizedDescription as Any)
                }
                DispatchQueue.main.async {
                    self.storage.setValue(data , forKey: url)
                    NotificationCenter.default.post(name: notCenter.SUCCESS_NOTIFICATION, object: url)
                }
            }).resume()
          
        }
        
    }
    func search(url: String) -> Data? {
        if (url != "" && storage.object(forKey: url) == nil) {
            save(url: url, data: nil)
        }else if (url == "") {
            return nil
        }
        return storage.object(forKey: url) as! Data?
    }
    
    func clear() -> Void {
        self.storage.removeAllObjects()
    }
}
extension StorageService : RequestStorageSvc {
    func inserted(metadata: FIRStorageMetadata, data: Data) {
        if let downloadURL = metadata.downloadURL()?.absoluteString {
            
            self.save(url: downloadURL, data: data)
        }
    }
}

