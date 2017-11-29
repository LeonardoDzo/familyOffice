//
//  Serializable.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 13/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
protocol Serializable : Codable {
}
extension Serializable {
    func toJSON() -> [String:Any]? {
        let encoder = JSONEncoder()
        guard  let data = try? encoder.encode(self) else { return nil}
        return try? JSONSerialization.jsonObject(with: data) as! [String:Any]
    }
}
