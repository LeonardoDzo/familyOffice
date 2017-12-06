//
//  IllnessActions.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/20/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

func getIllnessById(id: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(LoadingIllnessAction())
        Constants.FirDatabase.REF.child("illness/\(id)")
            .observeSingleEvent(of: .value, with: { snapshot in
                do {
                    guard snapshot.exists() else { throw IllnessError.NotFound }
                    guard let json = snapshot.value as? NSDictionary else { throw IllnessError.NotJson }
                    guard let data = json.jsonToData() else { throw IllnessError.NotData }
                    let entity = try JSONDecoder.decode(data, to: IllnessEntity.self)
                    rManager.save(objs: entity)
                    store.dispatch(DoneIllnessAction())
                } catch let err {
                    print(err)
                    store.dispatch(ErrIllnessAction(err: err))
                }
            })
        return nil
    }
}

func getIllnessByFamily(familyId: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(LoadingIllnessAction())
        Constants.FirDatabase.REF.child("illness")
            .queryOrdered(byChild: "family")
            .queryEqual(toValue: familyId)
            .observeSingleEvent(of: .value, with: { snapshot in
                do {
                    guard snapshot.exists() else { throw IllnessError.NotFound }
                    guard let json = snapshot.value as? NSDictionary else { throw IllnessError.NotJson }
                    guard let data = json.jsonToData() else { throw IllnessError.NotData }
                    let entities = try JSONDecoder.decode(data, to: [String: IllnessEntity].self)
                    rManager.saveObjects(objs: entities.values.filter({_ in true}))
                    store.dispatch(DoneIllnessAction())
                } catch let err {
                    print(err)
                    store.dispatch(ErrIllnessAction(err: err))
                }
            })
        return nil
    }
}

func newIllnessAction(illness: IllnessEntity) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(LoadingIllnessAction())
        let child = Constants.FirDatabase.REF.child("illness").childByAutoId()
        illness.id = child.key
        child.setValue(illness.toJSON())
        rManager.save(objs: illness)
        store.dispatch(DoneIllnessAction())
        return nil
    }
}

enum IllnessError: Error {
    case NotFound, NotJson, NotData
}

struct LoadingIllnessAction: Action {}
struct DoneIllnessAction: Action {}
struct ErrIllnessAction: Action {
    let err: Error
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
