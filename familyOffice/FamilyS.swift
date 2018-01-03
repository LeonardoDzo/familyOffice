//
//  FamilyS.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import RealmSwift
import Firebase


enum FamilyAction : description{
    case insert(family: FamilyEntity),
    uploadImage(img: UIImage, family: FamilyEntity),
    update(family: FamilyEntity),
    delete(fid: String),
    getbyId(fid: String),
    none
    
    init(){
        self =  .none
    }
    
}

class FamilyS: Action, EventProtocol {
    var handles = [(String, UInt, DataEventType)]()
    typealias EnumType = FamilyAction
    var action: FamilyAction = .none
    
    var status: Result<Any> = .none
    var id: String!
    var fromView: RoutingDestination!
    
    init() {
        self.status = .none
    }
    
    convenience init(_ action: FamilyAction) {
        self.init()
        self.id = UUID().uuidString
        self.action = action
        status = .loading
        self.fromView = RoutingDestination(rawValue: UIApplication.topViewController()?.restorationIdentifier ?? "" )
    }
    func getDescription() -> String {
        return "\(self.action.description) \(self.status.description)"
    }
    
    func delete(_ fid: String) {
        self.delete("families/\(fid)", callback: { deleted in
            if deleted {
                if let family = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: fid) {
                    rManager.deteObject(objs: family)
                }
                self.status = .Finished(self.action)
            }else{
                 self.status = .Failed(self.action)
              
            }
             store.dispatch(self)
        })
    }
    
    func create(family: FamilyEntity) -> Void {
        let ref = "families/\(family.id)"
        family.admins.append(RealmString(value: (Auth.auth().currentUser?.uid)!))
        family.members.append(RealmString(value: (Auth.auth().currentUser?.uid)!))
        if var json = family.toJSON() {
            json["admins"] =  family.admins.toNSArrayByKey()
            json["members"] = family.members.toNSArrayByKey()
            self.insert(ref, value: json, callback: { (response) in
                if response is DatabaseReference {
                    self.status = .Finished(self.action)
                }else{
                    self.status = .failed
                }
                store.dispatch(self)
            })
        }
    }
    func update(family: FamilyEntity) -> Void {
        let ref = "families/\(family.id)"
        if var famjson = family.toJSON() {
            famjson["admins"] =  family.admins.toNSArrayByKey()
            famjson["members"] = family.members.toNSArrayByKey()
            self.update(ref, value: famjson, callback: { ref in
                if ref is DatabaseReference {
                    rManager.save(objs: family)
                    self.status = .Finished(self.action)
                    store.dispatch(self)
                }else{
                    self.status = .Failed(self.action)
                    store.dispatch(self)
                }
            })
        }else{
            self.status = .Failed(self.action)
            store.dispatch(self)
        }
        
    }
    func uploadFamily(img: UIImage, family: FamilyEntity) -> Void {
        let imageName = NSUUID().uuidString
        self.uploadData("families/\(family.id)/images/\(imageName).jpg", value: img, callback: {(response) in
            if let metadata = response as? StorageMetadata {
                if let editFamily = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: family.id) {
                    try! rManager.realm.write {
                        editFamily.photoURL = (metadata.downloadURL()?.absoluteString)!
                        editFamily.imageProfilePath = metadata.path!
                        self.update(family: editFamily)
                    }
                    
                }else{
                    self.error()
                }
            }else{
                self.error()
            }
           
        })
    }
    
    func error() -> Void {
        self.status = .Failed(self.action)
        store.dispatch(self)
    }
    deinit {
        self.removeHandles()
    }
}
extension FamilyS : RequestProtocol, RequestStorageSvc {
    
    func inserted(metadata: StorageMetadata, data: Data) {
        
    }
    
    func notExistSnapshot(ref: String) {
        if let id = ref.components(separatedBy: "/").last {
            if let family = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: id) {
                rManager.deteObject(objs: family)
            }
        }
    }
    
    
    func added(snapshot: DataSnapshot) {
        do {
            if let dictionary = snapshot.value as? NSDictionary {
                if let data = dictionary.jsonToData() {
                    let family =  try JSONDecoder().decode(FamilyEntity.self, from: data)
                    rManager.save(objs: family)
                    let ref = ref_family(family.id)
                    sharedMains.initObserves(ref:ref, actions: [.childChanged])
                    self.status = .finished
                    store.dispatch(self)
                }else{
                    self.status = .Failed("Error al parsear datos")
                    store.dispatch(self)
                }
            }
            else{
                self.status = .Failed("Error al parsear datos")
                store.dispatch(self)
            }
        }catch let error {
            print(error)
            self.status = .Failed(error.localizedDescription)
            store.dispatch(self)
        }
        
        
    }
    func removed(snapshot: DataSnapshot) {
        let key : String = snapshot.key
        if let family = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: key) {
            rManager.realm.delete(family)
        }
        
    }
    
    func updated(snapshot: DataSnapshot, id: Any) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        if let index = store.state.FamilyState.families.indexOf(fid: id){
            store.state.FamilyState.families.items[index].update(snapshot: snapshot)
        }
    }
    
    
}

extension FamilyS : Reducer {
    typealias StoreSubscriberStateType = FamilyState
    func handleAction(state: FamilyState?) -> FamilyState {
        var state = state ?? FamilyState(families: FamilyList(), status: .none)
        state.status = self.status
        switch self.status {
            
        case .loading,  .Loading(_):
            
            switch self.action {
            case .insert(let family):
                self.create(family: family)
                break
            case .uploadImage(let img, let family):
                self.uploadFamily(img: img, family: family)
                break
            case .update(let family):
                self.update(family: family)
                break
            case .delete(let fid):
                self.delete(fid)
                break
            case .getbyId(let fid):
                self.valueSingleton(ref: "families/\(fid)")
                break
            case .none:
                break
            }
            break
        case .failed, .Failed(_):
            break
        case .finished:
            break
        case .Finished(_):
            break
        case .none, .noFamilies:
            break
        }
        return state
    }
}
