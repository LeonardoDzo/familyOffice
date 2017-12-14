//
//  MessagesActions.swift
//  familyOffice
//
//  Created by Nan Montaño on 13/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

let MESSAGES_REF = Constants.FirDatabase.REF.child("messages")

func getAllMessagesAction(groupId: String, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        MESSAGES_REF.queryOrdered(byChild: "groupId")
            .queryEqual(toValue: groupId)
            .observe(.value, with: { snapshot in
                do {
                    if !snapshot.exists() { throw RequestError.NotFound }
                    guard let json = snapshot.value as? NSDictionary else { throw RequestError.NotJson }
                    var entities = [MessageEntity]()
                    json.forEach({ key, value in
                        let dic = value as! NSDictionary
                        dic.setValue(key, forKey: "id")
                        dic.setValue(Date(dic["timestamp"] as! Int), forKey: "timestamp")
                        entities.append(MessageEntity(value: dic))
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

func createMessageAction(entity: MessageEntity, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        let child = MESSAGES_REF.childByAutoId()
        entity.id = child.key
        child.setValue(entity.toJSON())
        rManager.save(objs: entity)
        store.dispatch(RequestAction.Done(uuid: uuid))
        return nil
    }
}
