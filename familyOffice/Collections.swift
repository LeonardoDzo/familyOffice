//
//  Collections.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 14/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}
extension Dictionary  {
    
    var getKeysRealmString : [RealmString] {
        var values: [RealmString] = []
        forEach { (element) in
            if let key = element.key as? String {
                 values.append(RealmString(value: key))
            }
        }
        return values
    }
    
    var assistanPendings : [assistantpending] {
        var values: [assistantpending] = []
        forEach { (element) in
            if let key = element.key as? String, let value = element.value as? Bool {
                values.append(assistantpending(value, key))
            }
        }
        return values
    }
}

