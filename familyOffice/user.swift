//
//  User.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 26/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase
struct User {
    
    static let kUserNameKey = "name"
    static let kUserIdKey = "id"
    static let kUserPhotoUrlKey = "photoUrl"
    static let kUserFamiliesKey = "families"
    static let kEventKey = "events"
    static let kUserFamilyActiveKey = "familyActive"
    static let kUserPhoneKey = "phone"
    static let kUserCurpKey = "curp"
    static let kUserBirthdayKey = "birthday"
    static let kUserAddressKey = "address"
    static let kUserRFCKey = "rfc"
    static let kUserNSSKey = "nss"
    static let kUserBloodTypeKey = "bloodType"
    static let kUserTokensFCMeKey = "tokensFCM"
    static let kUserHealthKey = "health"
    
    let id: String!
    var name : String!
    var phone: String! = "Cargando..."
    var photoURL: String! = ""
    var families : NSDictionary? = nil
    var familyActive : String! = ""
    var rfc : String!
    var nss : String!
    var curp : String!
    var birthday: String!
    var address : String!
    var bloodtype: String!
    var tokens: NSDictionary? = nil
    var events: [String]? = []
    var health: Health!
    
    init() {
        self.name = "Cargando..."
        self.phone = "Cargando..."
        self.photoURL = ""
        self.families = nil
        self.familyActive = ""
        self.rfc = ""
        self.nss = ""
        self.curp = ""
        self.birthday = ""
        self.address = ""
        self.bloodtype = ""
        self.tokens = nil
        self.health = nil
        self.id = ""
    }

    init(id: String, name: String, phone: String,  photoURL: String, families: NSDictionary, familyActive: String, rfc: String, nss: String, curp: String, birth: String, address: String, bloodtype: String, health: NSArray) {
        self.name = name
        self.phone = phone
        self.photoURL = photoURL
        self.families = families
        self.familyActive = familyActive
        self.rfc = rfc
        self.nss = nss
        self.curp = curp
        self.birthday = birth
        self.address = address
        self.bloodtype = bloodtype
        self.tokens = nil
        self.health = Health(array: health)
        self.id = ""
    }
    
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! NSDictionary
        self.id = snapshot.key
        self.familyActive = service.UTILITY_SERVICE.exist(field: User.kUserFamilyActiveKey, dictionary: snapshotValue)
        self.health = Health(snapshot: snapshot.childSnapshot(forPath: "health"))
        self.fromDictionary(snapshotValue: snapshotValue) 
        
    }
    
    mutating func fromDictionary(snapshotValue: NSDictionary) -> Void {
        self.name = service.UTILITY_SERVICE.exist(field: User.kUserNameKey, dictionary: snapshotValue)
        self.photoURL = service.UTILITY_SERVICE.exist(field: User.kUserPhotoUrlKey, dictionary: snapshotValue)
        self.address = service.UTILITY_SERVICE.exist(field: User.kUserAddressKey, dictionary: snapshotValue )
        self.birthday = service.UTILITY_SERVICE.exist(field: User.kUserBirthdayKey, dictionary: snapshotValue )
        self.curp = service.UTILITY_SERVICE.exist(field: User.kUserCurpKey, dictionary: snapshotValue)
        self.rfc = service.UTILITY_SERVICE.exist(field: User.kUserRFCKey, dictionary: snapshotValue)
        self.nss = service.UTILITY_SERVICE.exist(field: User.kUserNSSKey, dictionary: snapshotValue)
        self.bloodtype = service.UTILITY_SERVICE.exist(field: User.kUserBloodTypeKey, dictionary: snapshotValue)
        self.families = service.UTILITY_SERVICE.exist(field: User.kUserFamiliesKey, dictionary: snapshotValue)
        self.phone = service.UTILITY_SERVICE.exist(field: User.kUserPhoneKey, dictionary: snapshotValue)
        self.tokens = service.UTILITY_SERVICE.exist(field: User.kUserTokensFCMeKey, dictionary: snapshotValue)
        self.events = service.UTILITY_SERVICE.exist(field: User.kEventKey, dictionary: snapshotValue)
    }
    func toDictionary() -> NSDictionary {
        return [
            User.kUserNameKey : self.name!,
            User.kUserPhotoUrlKey : self.photoURL!,
            User.kUserFamilyActiveKey: self.familyActive!,
            User.kUserRFCKey: self.rfc!,
            User.kUserCurpKey: self.curp!,
            User.kUserAddressKey: self.address!,
            User.kUserNSSKey: self.nss!,
            User.kUserBloodTypeKey: self.bloodtype!,
            User.kUserPhoneKey : self.phone!,
            User.kUserBirthdayKey : self.birthday!,
            User.kUserHealthKey : self.health.toDictionary()
        ]
    }
    
    mutating func update(snapshot: DataSnapshot){
        switch snapshot.key {
        case  User.kUserPhotoUrlKey:
            self.photoURL =  snapshot.value! as! String
            break
        case User.kUserFamiliesKey:
            self.families = snapshot.value! as? NSDictionary
            break
        case User.kUserHealthKey:
            self.health = Health(snapshot: snapshot)
            break
        case User.kUserFamilyActiveKey:
            self.familyActive = snapshot.value! as! String
            break
        default:
            break
        }
    }
}
extension User: Equatable {
    /// Equality check ignoring the `familyId`.
    func hasEqualContent(_ other: User) -> Bool {
        return other.id == id
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}


protocol UserModelBindable: AnyObject {
    var userModel: User? { get set }
    var filter: String! { get set}
    var nameLabel: UILabel! {get}
    var profileImage: CustomUIImageView! {get}
    var phoneLbl: UILabel! {get}
}

extension UserModelBindable {
    // Make the views optionals
    
    var nameLabel: UILabel! {
        return nil
    }
    
    var profileImage: CustomUIImageView! {
        return nil
    }
    
    var phoneLbl : UILabel! {
        return nil
    }
    
    
    
    // Bind
    
    func bind(userModel: User, filter: String = "") {
        self.userModel = userModel
        self.filter = filter
        bind()
    }
    
    func bind() {
        
        guard let userModel = self.userModel else {
            return
        }
        
        if let nameLabel = self.nameLabel {
            nameLabel.text = userModel.name
        }
        if let phoneLbl = self.phoneLbl {
            phoneLbl.text = userModel.phone
        }
        
        
        if let profileImage = self.profileImage {
            if !userModel.photoURL.isEmpty {
                profileImage.loadImage(urlString: userModel.photoURL, filter: filter)
            }else{
                profileImage.image = #imageLiteral(resourceName: "profile_default")
            }
        }
        
        
    }
}

