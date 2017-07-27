//
//  Health.swift
//  familyOffice
//
//  Created by Nan Montaño on 14/mar/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

struct Health {
    
    var elements = [Element]()
    
    init(array: NSArray){
        elements = array.map({ Element(dic: $0 as! NSDictionary) })
    }
    
    init() {
    }
    
    init(elements: [Element]){
        self.elements = elements
    }
    
    init(snapshot: FIRDataSnapshot){
        let snapArray = snapshot.value as? NSArray
        self.init(array: snapArray ?? [])
    }
    
    func toDictionary() -> [NSDictionary] {
        return elements.map({ $0.toDictionary() })
    }
    
    struct Element {
        static let kElementName = "name"
        static let kElementType = "type"
        static let kElementDescription = "description"
        
        static let typeMed = 0
        static let typeDisease = 1
        static let typeDoctor = 2
        static let typeOperation = 3
        
        var name: String
        var type: Int
        var description: String
        
        init(name: String, type: Int, description: String){
            self.name = name
            self.type = type
            self.description = description
        }
        
        init(dic: NSDictionary){
            self.name = service.UTILITY_SERVICE.exist(field: Element.kElementName, dictionary: dic)
            
            self.type = dic[Element.kElementType] as? Int ?? 0
            self.description = service.UTILITY_SERVICE.exist(field: Element.kElementDescription, dictionary: dic)
        }
        
        init(snapshot: FIRDataSnapshot){
            let snapDic = snapshot.value as! NSDictionary
            self.init(dic: snapDic)
        }
        
        func toDictionary() -> NSDictionary {
            return [
                Element.kElementName : self.name,
                Element.kElementType : self.type,
                Element.kElementDescription : self.description
            ]
        }
    }
    
}

protocol ElementBindable {
    var element : Health.Element? { get set }
    var iconImageView : UIImageView! { get }
    var nameLabel : UILabel! { get }
    var descriptionLabel : UILabel! { get }
}

extension ElementBindable {
    
    var iconImageView : UIImageView! { return nil }
    var nameLabel : UILabel! { return nil }
    var descriptionLabel : UILabel! { return nil }
    
    mutating func bindElement(element: Health.Element?){
        self.element = element
        bind()
    }
    
    func bind() {
        guard let element = self.element else { return }
        if let imageView = self.iconImageView {
            switch element.type {
            case Health.Element.typeMed: imageView.image = #imageLiteral(resourceName: "pill"); break
            case Health.Element.typeDisease: imageView.image = #imageLiteral(resourceName: "disease"); break
            case Health.Element.typeDoctor: imageView.image = #imageLiteral(resourceName: "doctor"); break
            case Health.Element.typeOperation: imageView.image = #imageLiteral(resourceName: "operation"); break
            default: break
            }
        }
        if let nameLabel = self.nameLabel {
            nameLabel.text = element.name
        }
        if let descriptionLabel = self.descriptionLabel {
            descriptionLabel.text = element.description
        }
    }
    
}
