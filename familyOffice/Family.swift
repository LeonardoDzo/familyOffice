//
//  family.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 06/01/17.
//  Copyright © 2017 Miguel Reina y Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

struct Family {
    
    static let kFamilyIdKey = "id"
    static let kFamilyNameKey = "name"
    static let kFamilyPhotoUrlKey = "photoUrl"
    static let kFamilyMembersKey = "members"
    static let kFamilyAdminKey = "admin"
    static let kFamilyImagePathKey = "imageProfilePath"
    
    var id: String!
    var name: String!
    var photoURL: String?
    var imageProfilePath : String?
    var totalMembers : UInt? = 0
    var admin : String? = ""
    var members : [String]!
    let firebaseReference: FIRDatabaseReference?
    var goals: [Goal]! = []
    /* Initializer for instantiating a new object in code.
     */
    init(){
        self.id = ""
        self.name = ""
        self.photoURL = nil
        self.admin = ""
        self.totalMembers = 0
        self.firebaseReference = nil
        self.members = []
    }
    
    init(name: String, photoURL: String, members: [String], admin: String,  imageProfilePath: String? ){
        self.name = name
        self.photoURL = photoURL
        self.admin = admin
        self.totalMembers = 0
        self.firebaseReference = nil
        self.members = members
        self.imageProfilePath = imageProfilePath
    }
    mutating func setId() -> Void {
       self.id =  Constants.FirDatabase.REF.child("families").childByAutoId().key
    }
    
    /* Initializer for instantiating an object received from Firebase.
     */
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! NSDictionary
        self.id = snapshot.key
        self.name = service.UTILITY_SERVICE.exist(field: Family.kFamilyNameKey, dictionary: snapshotValue)
        self.imageProfilePath = service.UTILITY_SERVICE.exist(field: Family.kFamilyImagePathKey, dictionary: snapshotValue)
        self.photoURL = service.UTILITY_SERVICE.exist(field: Family.kFamilyPhotoUrlKey, dictionary: snapshotValue)
        self.members = service.UTILITY_SERVICE.exist(field: Family.kFamilyMembersKey, dictionary: snapshotValue)
        self.admin = service.UTILITY_SERVICE.exist(field: Family.kFamilyAdminKey, dictionary: snapshotValue)
        self.firebaseReference = snapshot.ref
    }
    
    /* Method to help updating values of an existing object.
     */
    func toDictionary() -> Any {
        
        
        return [
            Family.kFamilyNameKey: self.name,
            Family.kFamilyPhotoUrlKey: self.photoURL!,
            Family.kFamilyMembersKey : service.UTILITY_SERVICE.toDictionary(array: self.members),
            Family.kFamilyAdminKey : self.admin ?? "",
            Family.kFamilyImagePathKey: self.imageProfilePath!
        ]
    }
    
    mutating func update(snapshot: FIRDataSnapshot){
        guard let value = snapshot.value! as? NSDictionary else {
            return
        }
        
        
        switch snapshot.key {
        case  Family.kFamilyNameKey:
            self.name = snapshot.value! as! String
            break
        case Family.kFamilyMembersKey:
            self.members = service.UTILITY_SERVICE.exist(field: Family.kFamilyMembersKey, dictionary: value)
            break
        case Family.kFamilyPhotoUrlKey:
            self.photoURL = snapshot.value as? String
            break
        case Family.kFamilyAdminKey:
            self.admin = snapshot.value as? String
        default:
            break
        }
    }
    
}
extension Family: Equatable {
    /// Equality check ignoring the `familyId`.
    func hasEqualContent(_ other: Family) -> Bool {
        return other.id == id
    }
}

func ==(lhs: Family, rhs: Family) -> Bool {
    return lhs.id == rhs.id
}

//Bind Galleries

protocol FamilyBindable: AnyObject {
    var family: Family! {get set}
    var Title: UIKit.UILabel! {get}
    var Image: CustomUIImageView! {get}
    var check: UIImageView! { get }
    var nameTxt: textFieldStyleController! {get}
}
extension FamilyBindable{
    var Title: UIKit.UILabel!{
        return nil
    }
    var Image: CustomUIImageView!{
        return nil
    }
    var check: UIKit.UIImageView!{
        return nil
    }
    var nameTxt: textFieldStyleController! {
        return nil
    }
    //Bind Ninja
    func bind(fam: Family){
        self.family = fam
        bind()
    }
    func bind() {
        guard let family = self.family else{
            return
        }
        if let titleLabel = self.Title{
            if family.name != nil{
                titleLabel.text = (family.name?.isEmpty)! ? "Sin título" : family.name
            }else{
                titleLabel.text = "Sin título"
            }
        }
        if let nameTxt = self.nameTxt{
            if family.name != nil{
                nameTxt.text = (family.name?.isEmpty)! ? "" : family.name
            }
        }
        if let imageBackground = self.Image{
            if family.photoURL != nil{
                if(!(family.photoURL?.isEmpty)!){
                    imageBackground.loadImage(urlString: family.photoURL!)
                }else{
                    imageBackground.image = #imageLiteral(resourceName: "familyImage")
                }
            }
        }
        if let check = self.check{
            if family.id == store.state.UserState.user?.familyActive {
                check.isHidden = false
            }else{
                check.isHidden = true
            }
        }
    }
}

