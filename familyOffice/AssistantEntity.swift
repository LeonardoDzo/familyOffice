//
//  AssistantEntity.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 19/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift
@objcMembers
class AssistantEntity: Object, Serializable {
    dynamic var id: String = ""
    dynamic var email: String = "Sin email"
    dynamic var name : String = "Sin Nombre"
    dynamic var phone: String = ""
    dynamic var photoURL: String = ""
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}

protocol AssistantBindable: AnyObject, bind, Base {
    var userModel: AssistantEntity! { get set }
    var nameLabel: UILabel! {get}
    var phoneLbl: UILabel! {get}
    var familycounterLbl: UILabel! {get}
    var profileImage: UIImageViewX! {get}
    var birthdaylbl: UILabel!  {get}
    var bloodtypeLbl: UILabel!  {get}
    var addressLbl: UILabel!  {get}
    var rfcLbl: UILabel!  {get}
    var nssLbl: UILabel! {get}
}

extension AssistantBindable  {
    // Make the views optionals
    
    var nameLabel: UILabel! {
        return nil
    }
    var addressLbl: UILabel! {
        return nil
    }
    var titleLbl : UILabel! {
        return nil
    }
    var birthdaylbl: UILabel! {
        return nil
    }
    var bloodtypeLbl: UILabel! {
        return nil
    }
    var rfcLbl: UILabel! {
        return nil
    }
    var nssLbl: UILabel! {
        return nil
    }
    var phoneLbl: UILabel! {
        return nil
    }
    var subtitleLbl : UILabel! {
        return nil
    }
    var photo : UIImageViewX! {
        return nil
    }
    var familycounterLbl: UILabel! {
        return nil
    }
    
    
    var profileImage: UIImageViewX! {
        return nil
    }
    
    
    func bind(sender: Any?) -> Void {
        if sender is UserEntity {
            bind(userModel: sender as! AssistantEntity)
        }
    }
    
    // Bind
    
    func bind(userModel: AssistantEntity, filter: String = "") {
        self.userModel = userModel
        bind()
    }
    
    func bind() {
        
        guard let userModel = self.userModel else {
            return
        }
        
        if let nameLabel = self.nameLabel {
            nameLabel.text = userModel.name.uppercased()
        }
        if let titleLbl = self.titleLbl {
            titleLbl.text = userModel.name.uppercased()
        }
        if let subtitle = self.subtitleLbl {
            subtitle.text = userModel.phone
        }
        
        if let photo = self.photo {
            if !userModel.photoURL.isEmpty {
                photo.loadImage(urlString: userModel.photoURL)
            }else{
                photo.image = #imageLiteral(resourceName: "user-default")
            }
        }
        
        if let phoneLbl = self.phoneLbl {
            phoneLbl.text = !userModel.phone.isEmpty ? self.userModel.phone : "Sin capturar"
        }
        
        if let profileImage = self.profileImage {
            if !userModel.photoURL.isEmpty {
                profileImage.loadImage(urlString: userModel.photoURL)
            }else{
                profileImage.image = #imageLiteral(resourceName: "user-default")
            }
        }
        
        
    }
}

