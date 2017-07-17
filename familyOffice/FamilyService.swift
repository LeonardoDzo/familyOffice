//
//  FamilyService.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 11/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import UIKit

class FamilyService: repository, RequestService {
    func notExistSnapshot() {
        
    }

    
    func addHandle(_ handle: UInt, ref: String, action: FIRDataEventType) {
        
    }

    var handles: [(String, UInt, FIRDataEventType)] = []

    var families: [Family] = []

    
    func insert(_ ref: String, value: Any, callback: @escaping ((Any) -> Void)) {
        
        Constants.FirDatabase.REF.child(ref).setValue(value, withCompletionBlock: {(error, ref) in
            
            if error != nil {
                print(error.debugDescription)
            }else{
                DispatchQueue.main.async {
                    callback(ref.key)
                }
            }
        })
    }
    
    func delete(_ ref: String, callback: @escaping ((Any) -> Void)) {
        
    }

    func update(_ ref: String, value: [AnyHashable : Any], callback: @escaping ((Any) -> Void)) {
        
    }
    
    private static let instance : FamilyService = FamilyService()
    
    
    private init() {
    }
    
    public static func Instance() -> FamilyService {
        return instance
    }
    
    func added(snapshot: FIRDataSnapshot) {
        let family : Family = Family(snapshot: snapshot)
        
        if !self.families.contains(where: { $0.id == family.id }) {
            self.families.append(family)
            store.state.FamilyState.families.append(family)
            NotificationCenter.default.post(name: notCenter.FAMILYADDED_NOTIFICATION, object: family)
            ToastService.getTopViewControllerAndShowToast(text: "Fam. agregada: \(family.name!)")
        }else{
            if let index = self.families.index(where: {$0.id == family.id}){
                self.families[index] = family
                ToastService.getTopViewControllerAndShowToast(text: "Familia actualizada: \(family.name!)")
                NotificationCenter.default.post(name: notCenter.FAMILYUPDATED_NOTIFICATION, object: index)
            }
        }
        
    }
    
    func removed(snapshot: FIRDataSnapshot) -> Void {
        let key : String = snapshot.key
        //Actualizo la información de familias al usuario logeado
        if let index = service.USER_SERVICE.users.index(where: {$0.id == FIRAuth.auth()?.currentUser?.uid})  {
            let filter =  service.USER_SERVICE.users[index].families?.filter({$0.key as? String != key})
            var families : [String: Bool] = [:]
            for result in filter! {
                families[result.key as! String] = (result.value as! Bool)
            }
            service.USER_SERVICE.users[index].families = families as NSDictionary
        }
        //Elimino la familia localmente
        if let index = self.families.index(where: {$0.id == key}){
            let family = self.families[index]
            self.families.remove(at: index)
            verifyFamilyActive(family: family)
            ToastService.getTopViewControllerAndShowToast(text: "Familia eliminada: \(family.name!)")
            NotificationCenter.default.post(name: notCenter.FAMILYREMOVED_NOTIFICATION, object: index)
        }
    }
    
    func updated(snapshot: FIRDataSnapshot, id: Any) {
        if let index = service.FAMILY_SERVICE.families.index(where: { $0.id == id as! String }){
            self.families[index].update(snapshot: snapshot)
            NotificationCenter.default.post(name: notCenter.FAMILYUPDATED_NOTIFICATION, object: index)
        }
    }
    
    func delete(family : Family) {
        
    }
    
    func exitFamily(family: Family, uid:String) -> Void {
        Constants.FirDatabase.REF_USERS.child("/\(uid)/families/\((family.id)!)").removeValue()
        Constants.FirDatabase.REF_FAMILIES.child("/\((family.id)!)/members/\(uid)").removeValue()
        if(family.admin == service.USER_SERVICE.users[0].id){
            self.addAdmin(index: self.families.index(where: {$0.id == family.id})!, uid: nil)
        }
    }
    
    func addAdmin(index: Int, uid: String?) -> Void {
        if(uid != nil){
            self.families[index].admin = uid
        }else{
            if (self.families[index].members?.count)! > 1 {
                for item in self.families[index].members {
                    if(service.USER_SERVICE.users[0].id != item){
                        self.families[index].admin = item
                        Constants.FirDatabase.REF_FAMILIES.child(self.families[index].id).updateChildValues(["admin": item])
                        break
                    }
                }
            }else{
                delete(family: self.families[index])
            }
        }
    }
    
    func verifyFamilyActive(family: Family) -> Void {
        if(family.id == service.USER_SERVICE.users[0].familyActive){
            if(self.families.count > 0){
                self.selectFamily(family: self.families[0])
            }else{
                NotificationCenter.default.post(name: notCenter.NOFAMILIES_NOTIFICATION, object: nil)
            }
        }
    }
    
    func selectFamily(family: Family) -> Void {
        Constants.FirDatabase.REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).updateChildValues(["familyActive" : family.id])
        service.USER_SERVICE.setFamily(family: family)
    }

    func addHandle(_ handle: UInt) {
    }

    func removeHandles() {
    }

    func inserted(ref: FIRDatabaseReference) {
    }

    func routing(snapshot: FIRDataSnapshot, action: FIRDataEventType, ref: String) {
    }

}

extension FamilyService {
    //Added members
    func added(snapshot: FIRDataSnapshot, id: String) -> Void {
        let familyID = id
        let memberID = snapshot.key
        if let index = self.families.index(where: {$0.id == familyID}) {
            self.families[index].members.append(memberID)
            Constants.FirDatabase.REF_FAMILIES.child("\(familyID)/members").updateChildValues([memberID: true])
            Constants.FirDatabase.REF_USERS.child("\(memberID)/families").updateChildValues([familyID:true])
            NotificationCenter.default.post(name: notCenter.SUCCESS_NOTIFICATION, object: [memberID:"added"])
        }
    }
    func addMember(uid: String, fid: String) -> Void {
        
        if let index = self.families.index(where: {$0.id == fid}) {
           
            self.families[index].members.append(uid)
            Constants.FirDatabase.REF_FAMILIES.child("\(fid)/members").updateChildValues([uid : true])
            Constants.FirDatabase.REF_USERS.child("\(uid)/families").updateChildValues([fid:true])
            service.NOTIFICATION_SERVICE.send(title: "Agregado a: ", message: self.families[index].name!, to: uid)
            service.NOTIFICATION_SERVICE.saveNotification(id: uid, title: "Agregado a: \(self.families[index].name!)", photo: self.families[index].photoURL!)
            ToastService.getTopViewControllerAndShowToast(text: "Miembro \((service.USER_SERVICE.users.first(where: {$0.id == uid})?.name).unsafelyUnwrapped) Agregado")
            //NotificationCenter.default.post(name: SUCCESS_NOTIFICATION, object: [uid:"added"])
        }
    }
    //Remove members
    func remove(snapshot: Any, id: Any) -> Void {
        let familyID = id as! String
        let memberID = snapshot as! String
        if let index = self.families.index(where: {$0.id == familyID})  {
            guard let memberIndex = self.families[index].members.index(where: {$0 ==  memberID}) else {
                print("usuario no encontrado")
                return
            }
            
            self.families[index].members.remove(at: memberIndex)
            
            if !self.families[index].members.contains(memberID){
                self.families.remove(at: index)
            }
            Constants.FirDatabase.REF_USERS.child("\((memberID))/families/\((familyID))").removeValue()
            Constants.FirDatabase.REF_FAMILIES.child("\(familyID)/members/\(memberID)").removeValue()

            NotificationCenter.default.post(name: notCenter.SUCCESS_NOTIFICATION, object: [memberID : "removed"])
        }
    }
}
