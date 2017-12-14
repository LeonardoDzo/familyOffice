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

func getAllGroupsAction(familyId: String, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        GROUPS_REF.queryOrdered(byChild: "familyId")
            .queryEqual(toValue: familyId)
            .observe(.value, with: { snapshot in
                do {
                    guard snapshot.exists() else { throw RequestError.NotFound }
                    guard let json = snapshot.value as? NSDictionary else { throw RequestError.NotJson }
                    var entities = [GroupEntity]()
                    json.forEach({ key, val in
                        let dic = val as! NSDictionary
                        dic.setValue(key, forKey: "id")
                        let members = dic["members"] as! NSDictionary
                        dic.setValue(members.allKeys.map({ RealmString(value: [$0]) }), forKey: "members")
                        let messages = dic["messages"] as? NSDictionary ?? [:]
                        dic.setValue(messages.allKeys.map({ RealmString(value: [$0]) }), forKey: "messages")
                        let createdAt = dic["createdAt"] as! Int
                        dic.setValue(Date(createdAt), forKey: "createdAt")
                        entities.append(GroupEntity(value: dic))
                    })
                    rManager.saveObjects(objs: entities)
                    store.dispatch(RequestAction.Done(uuid: uuid))
                } catch let err {
                    store.dispatch(RequestAction.Error(err: err as! RequestError, uuid: uuid))
                }
            })
        return nil
    }
}
