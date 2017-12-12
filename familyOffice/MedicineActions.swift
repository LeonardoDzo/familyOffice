//
//  MedicineActions.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/19/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

let MEDICINES_REF = Constants.FirDatabase.REF.child("medicines")

func getMedicineAction(familyId: String, byId id: String, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        MEDICINES_REF.child("\(familyId)\(id)")
            .observeSingleEvent(of: .value, with: { snapshot in
                do {
                    guard snapshot.exists() else { throw RequestError.NotFound }
                    guard let json = snapshot.value as? NSDictionary else { throw RequestError.NotJson }
                    json.setValue(familyId, forKey: "family")
                    json.setValue(id, forKey: "id")
                    guard let data = json.jsonToData() else { throw RequestError.NotData }
                    let entity = try JSONDecoder.decode(data, to: MedicineEntity.self)
                    rManager.save(objs: entity)
                    store.dispatch(RequestAction.Done(uuid: uuid))
                } catch let err {
                    store.dispatch(RequestAction.Error(err: err as! RequestError, uuid: uuid))
                }
            })
        return nil
    }
}

func getMedicinesAction(byFamily familyId: String, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        MEDICINES_REF.child(familyId)
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
                    let entities = try JSONDecoder.decode(data, to: [String: MedicineEntity].self)
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

func newMedicineAction(medicine: MedicineEntity, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        let child = MEDICINES_REF.child(medicine.family).childByAutoId()
        medicine.id = child.key
        child.setValue(medicine.toJSON())
        rManager.save(objs: medicine)
        store.dispatch(RequestAction.Done(uuid: uuid))
        return nil
    }
}

func editMedicineAction(medicine: MedicineEntity, fields: MedicineEntity, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        try! rManager.realm.write {
            medicine.name = fields.name
            medicine.dosage = fields.dosage
            medicine.indications = fields.indications
            medicine.restrictions = fields.restrictions
            medicine.moreInfo = fields.moreInfo
        }
        MEDICINES_REF.child("\(medicine.family)/\(medicine.id)").setValue(medicine.toJSON())
        store.dispatch(RequestAction.Done(uuid: uuid))
        return nil
    }
}

func removeMedicineAction(medicine: MedicineEntity, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        MEDICINES_REF.child("\(medicine.family)/\(medicine.id)").removeValue()
        rManager.deteObject(objs: medicine)
        store.dispatch(RequestAction.Done(uuid: uuid))
        return nil
    }
}

struct InsertMedicineAction: Action {
    var medicine: Medicine!
    init(medicine: Medicine){
        self.medicine = medicine
    }
}

struct UpdateMedicineAction: Action {
    var medicine: Medicine!
    init(medicine: Medicine){
        self.medicine = medicine
    }
}

struct DeleteMedicineAction: Action {
    var medicine: Medicine!
    init(medicine: Medicine){
        self.medicine = medicine
    }
}
