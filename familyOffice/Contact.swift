//
//  contact.swift
//  familyOffice
//
//  Created by Miguel Reina on 06/01/17.
//  Copyright © 2017 Miguel Reina. All rights reserved.
//

import Foundation
import Firebase

struct Contact  {
    static let kContactIdKey = "id"
    static let kContactNameKey = "name"
    static let kContactPhoneKey = "phone"
    static let kContactJobKey = "job"
    static let kContactAddressKey = "address"
    static let kContactWebPageKey = "webpage"
    static let kContactEmailKey = "email"
    
    let id: String!
    var name: String!
    var phone: String?
    var job : String!
    var address : String?
    var webpage : String?
    var email : String?
    let firebaseReference: FIRDatabaseReference?
    
    /* Initializer for instantiating a new object in code.
     */
    init(name: String, phone: String, job: String, address: String, webpage: String, email: String){
        self.name = name
        self.phone = phone
        self.job = job
        self.address = address
        self.webpage = webpage
        self.email = email
        self.firebaseReference = nil
        self.id = Constants.FirDatabase.REF.childByAutoId().key
    }
    
    /* Initializer for instantiating an object received from Firebase.
     */
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! NSDictionary
        self.id = snapshot.key
        self.name = service.UTILITY_SERVICE.exist(field: Contact.kContactNameKey, dictionary: snapshotValue)
        self.phone = service.UTILITY_SERVICE.exist(field: Contact.kContactPhoneKey, dictionary: snapshotValue)
        self.job = service.UTILITY_SERVICE.exist(field: Contact.kContactJobKey, dictionary: snapshotValue)
        self.address = service.UTILITY_SERVICE.exist(field: Contact.kContactAddressKey, dictionary: snapshotValue)
        self.webpage = service.UTILITY_SERVICE.exist(field: Contact.kContactWebPageKey, dictionary: snapshotValue)
        self.email = service.UTILITY_SERVICE.exist(field: Contact.kContactEmailKey, dictionary: snapshotValue)
        self.firebaseReference = snapshot.ref
    }
 
    /* Method to help updating values of an existing object.
     */
    func toDictionary() -> Any {
        
        return [
            Contact.kContactNameKey: self.name,
            Contact.kContactPhoneKey: self.phone,
            Contact.kContactJobKey : self.job,
            Contact.kContactAddressKey : self.address,
            Contact.kContactWebPageKey : self.webpage,
            Contact.kContactEmailKey : self.email
        ]
    }
   
    mutating func update(snapshot: FIRDataSnapshot){
        guard let value = snapshot.value! as? String else {
            return
        }
        
        switch snapshot.key {
        case Contact.kContactNameKey:
            self.name = value
            break
        case Contact.kContactJobKey:
            self.job = value
            break
        case Contact.kContactPhoneKey:
            self.phone = value
            break
        case Contact.kContactAddressKey:
            self.address = value
            break
        case Contact.kContactWebPageKey:
            self.webpage = value
            break
        case Contact.kContactEmailKey:
            self.email = value
            break
        default:
            break
        }
    }
    
}

protocol ContactBindible: AnyObject {
    var contact : Contact! {get set}
    var nameLbl: UILabel! {get}
    var nameTxt: UITextField! {get}
    var jobLbl: UILabel! {get}
    var jobTxt: UITextField! {get}
    var phoneLbl: UILabel! {get}
    var phoneTxt: UITextField! {get}
    var addressLbl: UILabel! {get}
    var addressTxt: UITextField! {get}
    var webpageLbl: UILabel! {get}
    var webpageTxt: UITextField! {get}
    var emailLbl: UILabel! {get}
    var emailTxt: UITextField! {get}
}

extension ContactBindible {
    var nameLbl: UILabel! {return nil}
    var nameTxt: UITextField! {return nil}
    var jobLbl: UILabel! {return nil}
    var jobTxt: UITextField! {return nil}
    var phoneLbl: UILabel! {return nil}
    var phoneTxt: UITextField! {return nil}
    var addressLbl: UILabel! {return nil}
    var addressTxt: UITextField! {return nil}
    var webpageLbl: UILabel! {return nil}
    var webpageTxt: UITextField! {return nil}
    var emailLbl: UILabel! {return nil}
    var emailTxt: UITextField! {return nil}
    
    func bind(contact: Contact) -> Void {
        self.contact = contact
        self.bind()
    }
    
    func bind() -> Void {
        guard let contact = self.contact else {
            return
        }
        
        if let nameLbl = self.nameLbl {
            nameLbl.text = contact.name
        }
        
        if let nameTxt = self.nameTxt {
            nameTxt.text = contact.name
        }
        if let jobLbl = self.jobLbl {
            jobLbl.text = contact.job
        }
        if let jobTxt = self.jobTxt {
            jobTxt.text = contact.job
        }
        if let phoneLbl = self.phoneLbl {
            phoneLbl.text = contact.phone
        }
        if let phoneTxt = self.phoneTxt {
            phoneTxt.text = contact.phone
        }
        if let addressLbl = self.addressLbl {
            addressLbl.text = contact.address
        }
        if let addressTxt = self.addressTxt {
            addressTxt.text = contact.address
        }
        if let webpageLbl = self.webpageLbl {
            webpageLbl.text = contact.webpage
        }
        if let webpageTxt = self.webpageTxt {
            webpageTxt.text = contact.webpage
        }
        if let emailLbl = self.emailLbl {
            emailLbl.text = contact.email
        }
        if let emailTxt = self.emailTxt {
            emailTxt.text = contact.email
        }
        
    }
    
}
