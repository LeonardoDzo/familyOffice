//
//  NSDictionary.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 26/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

// MARK: - Extension para solamente verificar si contiene el campo solicitado en el diccionario sin que tire error.
extension NSDictionary {
    func exist(field: String) -> String! {
        if let value = self[field] as?  String {
            return value
        }else {
            return ""
        }
    }
    func exist(field: String) -> Double! {
        if let value = self[field] {
            return value as! Double
        }else {
            return 0.0
        }
    }
    func exist(field: String) -> Int! {
        if let value = self[field] {
            return value as! Int
        }else {
            return nil
        }
    }
    func exist(field: String) -> Bool! {
        if let value = self[field] {
            return value as! Bool
        }
        return nil
        
    }
    func exist(arrString field: String) -> [String]! {
        if let value = self[field] as? NSDictionary {
            return value.allKeys as! [String]
        }else {
            return []
        }
    }

    func exist(array field: String) -> [Any] {
        if let value = self[field] {
            return value as! Array<Any>
        }else {
            return []
        }
    }
    func exist(dic field: String) -> NSDictionary? {
        guard let value = self[field] as? NSDictionary else {
            return nil
        }
        return value
    }
    
    func exist(strBool field: String) -> [String:Bool] {
        guard let value = self[field] as? NSDictionary else {
            return [:]
        }
        return value as! [String : Bool]
    }
    
    func exist(strInt field: String) -> [String:Int] {
        guard let value = self[field] as? NSDictionary else {
            return [:]
        }
        return value as! [String : Int]
    }
    func jsonToData() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
}
