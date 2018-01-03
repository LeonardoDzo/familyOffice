//
//  GroupsAction.swift
//  familyOffice
//
//  Created by Nan Montaño on 13/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

let GROUPS_REF = Constants.FirDatabase.REF.child("groups")

func getAllGroupsAction(uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        GROUPS_REF.observe(.value, with: { snapshot in
                do {
                    guard snapshot.exists() else { throw RequestError.NotFound }
                    guard let json = snapshot.value as? NSDictionary else { throw RequestError.NotJson }
                    var entities = [GroupEntity]()
                    json.forEach { (key, val) in
                        entities.append(GroupEntity.fromJSON(key: key as! String, json: val as! NSDictionary))
                    }
                    rManager.saveObjects(objs: entities)
                    store.dispatch(RequestAction.Done(uuid: uuid))
                } catch let err {
                    store.dispatch(RequestAction.Error(err: err as! RequestError, uuid: uuid))
                }
            })
        return nil
    }
}

func createGroupAction(group: GroupEntity, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        let child = GROUPS_REF.child(uuid)
        group.id = uuid
        child.setValue(group.toJSON())
        rManager.save(objs: group)
        store.dispatch(RequestAction.Done(uuid: uuid))
        return nil
    }
}

func editGroupAction(group: GroupEntity, fields: GroupEntity, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        do {
            store.dispatch(RequestAction.Loading(uuid: uuid))
            let child = GROUPS_REF.child(group.id)
            try rManager.realm.write {
                group.coverPhoto = fields.coverPhoto
                group.members = fields.members
                group.title = fields.title
            }
            child.setValue(group.toJSON())
            store.dispatch(RequestAction.Done(uuid: uuid))
        } catch {
            store.dispatch(RequestAction.Error(err: RequestError.CouldNotWrite, uuid: uuid))
        }
        return nil
    }
}

func addPhotoGroupAction(group: GroupEntity, photoUrl: String, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        do {
            store.dispatch(RequestAction.Loading(uuid: uuid))
            let child = GROUPS_REF.child(group.id)
            try rManager.realm.write {
                group.coverPhoto = photoUrl
            }
            child.setValue(group.toJSON())
//            rManager.save(objs: group)
            store.dispatch(RequestAction.Done(uuid: uuid))
        } catch {
            store.dispatch(RequestAction.Error(err: RequestError.CouldNotWrite, uuid: uuid))
        }
        return nil
    }
}

func seenGroupAction(group: GroupEntity, member: String, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        do {
            store.dispatch(RequestAction.Loading(uuid: uuid))
            let child = GROUPS_REF.child(group.id)
            try rManager.realm.write {
                let member = group.members.first(where: { $0.id == member })
                member?.time = Date()
            }
            child.setValue(group.toJSON())
//            rManager.save(objs: group)
            store.dispatch(RequestAction.Done(uuid: uuid))
        } catch {
            store.dispatch(RequestAction.Error(err: RequestError.CouldNotWrite, uuid: uuid))
        }
        return nil
    }
}
