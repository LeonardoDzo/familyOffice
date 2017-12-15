//
//  IllnessActions.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/20/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

let ILLNESSES_REF = Constants.FirDatabase.REF.child("illnesses")

func getIllnessAction(familyId: String, byId id: String, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        ILLNESSES_REF.child("\(familyId)/\(id)")
            .observeSingleEvent(of: .value, with: { snapshot in
                do {
                    guard snapshot.exists() else { throw RequestError.NotFound }
                    guard let json = snapshot.value as? NSDictionary else { throw RequestError.NotJson }
                    json.setValue(familyId, forKey: "family")
                    json.setValue(id, forKey: "id")
                    guard let data = json.jsonToData() else { throw RequestError.NotData }
                    let entity = try JSONDecoder.decode(data, to: IllnessEntity.self)
                    rManager.save(objs: entity)
                    store.dispatch(RequestAction.Done(uuid: uuid))
                } catch let err {
                    print(err)
                    store.dispatch(RequestAction.Error(err: err as! RequestError, uuid: uuid))
                }
            })
        return nil
    }
}

func getIllnessesAction(byFamily familyId: String, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        ILLNESSES_REF.child(familyId)
            .observe(.value, with: { snapshot in
                do {
                    guard snapshot.exists() else { throw RequestError.NotFound }
                    guard let json = snapshot.value as? NSDictionary else { throw RequestError.NotJson }
                    json.forEach({ (key, val) in
                        let dic = val as! NSDictionary
                        dic.setValue(familyId, forKey: "family")
                        dic.setValue(key, forKey: "id")
                    })
                    guard let data = json.jsonToData() else { throw RequestError.NotData }
                    let entities = try JSONDecoder.decode(data, to: [String: IllnessEntity].self)
                    rManager.saveObjects(objs: entities.values.filter({_ in true}))
                    store.dispatch(RequestAction.Done(uuid: uuid))
                } catch let err {
                    print(err)
                    store.dispatch(RequestAction.Error(err: err as! RequestError, uuid: uuid))
                }
            })
        return nil
    }
}

func newIllnessAction(illness: IllnessEntity, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        let child = ILLNESSES_REF.child(illness.family).childByAutoId()
        illness.id = child.key
        child.setValue(illness.toJSON())
        rManager.save(objs: illness)
        store.dispatch(RequestAction.Done(uuid: uuid))
        return nil
    }
}

func editIllnessAction(illness: IllnessEntity, fields: IllnessEntity, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        try! rManager.realm.write {
            illness.name = fields.name
            illness.dosage = fields.dosage
            illness.medicine = fields.medicine
            illness.moreInfo = fields.moreInfo
        }
        ILLNESSES_REF.child("\(illness.family)/\(illness.id)").setValue(illness.toJSON())
        store.dispatch(RequestAction.Done(uuid: uuid))
        return nil
    }
}

func removeIllnessAction(illness: IllnessEntity, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        ILLNESSES_REF.child("\(illness.family)/\(illness.id)").removeValue()
        rManager.deteObject(objs: illness)
        store.dispatch(RequestAction.Done(uuid: uuid))
        return nil
    }
}

struct InsertIllnessAction: Action {
    var illness: Illness!
    init(illness: Illness){
        self.illness = illness
    }
}

struct UpdateIllnessAction: Action {
    var illness: Illness!
    init(illness: Illness){
        self.illness = illness
    }
}

struct DeleteIllnessAction: Action {
    var illness: Illness!
    init(illness: Illness){
        self.illness = illness
    }
}
