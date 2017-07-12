//
//  ToDoList.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/3/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

struct ToDoList{
    var items: [ToDoItem]
    
    init(array: NSArray){
        items = array.map({ToDoItem(dic: $0 as! NSDictionary) })
    }
    
    init(items: [ToDoItem]){
        self.items = items
    }
    
    init(snapshot: FIRDataSnapshot){
        let snapArray = snapshot.value as? NSArray
        self.init(array: snapArray ?? [])
    }
    
    func toDictionary() -> [NSDictionary]{
        return items.map({$0.toDictionary()})
    }
    
    struct ToDoItem{
        static let itemKey = "id"
        static let titleKey = "title"
        static let photoUrlKey = "photoUrl"
        static let statusKey = "status"
        
        var id: String?
        var title: String!
        var photoUrl: String?
        var status: String!
        
        init(title: String, photoUrl: String, status: String){
            self.title = title
            self.photoUrl = photoUrl
            self.status = status
            self.id = Constants.FirDatabase.REF.childByAutoId().key
        }
        
        init(dic: NSDictionary){
            
            
        }
        
        init(snapshot: FIRDataSnapshot){
            let dic = snapshot.value as! NSDictionary
            self.id  = snapshot.key
            self.title = service.UTILITY_SERVICE.exist(field: ToDoItem.titleKey, dictionary: dic)
            self.photoUrl = service.UTILITY_SERVICE.exist(field: ToDoItem.photoUrlKey, dictionary: dic)
            self.status = service.UTILITY_SERVICE.exist(field: ToDoItem.statusKey, dictionary: dic)
        }
        
        func toDictionary() -> NSDictionary {
            return [
                ToDoItem.titleKey: self.title,
                ToDoItem.photoUrlKey: self.photoUrl,
                ToDoItem.statusKey: self.status
            ]
        }
        
    }
    
}
