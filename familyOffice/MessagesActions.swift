//
//  MessagesActions.swift
//  familyOffice
//
//  Created by Nan Montaño on 13/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Firebase

let MESSAGES_REF = Constants.FirDatabase.REF.child("messages")

func getAllMessagesAction(groupId: String, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        MESSAGES_REF.queryOrdered(byChild: "groupId")
            .queryEqual(toValue: groupId)
            .observe(.childAdded, with: { _messageReceived(snapshot: $0, uuid: uuid)})
        MESSAGES_REF.queryOrdered(byChild: "groupId")
            .queryEqual(toValue: groupId)
            .observe(.childChanged, with: { _messageReceived(snapshot: $0, uuid: uuid)})
        return nil
    }
}

func getMessageAction(messageId: String, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        MESSAGES_REF.child(messageId)
            .observe(.value, with: { _messageReceived(snapshot: $0, uuid: uuid) })
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

private func _messageReceived(snapshot: DataSnapshot, uuid: String) {
    do {
        if !snapshot.exists() { throw RequestError.NotFound }
        guard let json = snapshot.value as? NSDictionary else { throw RequestError.NotJson }
        json.setValue(snapshot.key, forKey: "id")
        json.setValue(Date(json["timestamp"] as! Int), forKey: "timestamp")
        let entity = MessageEntity(value: json)
        rManager.save(objs: entity)
        store.dispatch(RequestAction.Done(uuid: uuid))
    } catch let err {
        store.dispatch(RequestAction.Error(err: err as! RequestError, uuid: uuid))
    }
}
