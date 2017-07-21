//
//  FamilyList.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 18/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
struct FamilyList {
    var items: [Family]
    
    init() {
        self.items = []
    }
    mutating func appendItem(_ family: Family) {
        
        items.append(family)
    }
    mutating func insertItem(_ family: Family, atIndex index: Int) {
        
        if index < 1 {
            items.insert(family, at: 0)
        } else if index < items.count {
            items.insert(family, at: index)
        } else {
            items.append(family)
        }
    }
    
    func indexOf(fid: String) -> Int? {
        return items.index(where: { $0.id == fid })
    }
    
    func family(fid: String) -> Family? {
        
        guard let index = indexOf(fid: fid)
            else { return nil }
        
        return items[index]
    }
    
    mutating func removeItem(fid: String) {
        
        guard let index = indexOf(fid: fid)
            else { return }
        
        items.remove(at: index)
    }
    
    func hasEqualContent(_ other: Family) -> Bool {
        guard items.contains(where: {$0.hasEqualContent(other)}) else {
            return false
        }
        return true
    }
}
