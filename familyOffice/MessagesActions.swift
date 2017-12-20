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
            .observeSingleEvent(of: .value, with: { _messageReceived(snapshot: $0, uuid: uuid) })
        return nil
    }
}

func createMessageAction(entity: MessageEntity, uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        store.dispatch(RequestAction.Loading(uuid: uuid))
        let child = MESSAGES_REF.child(entity.id)
        do {
            try rManager.realm.write {
                entity.status = MessageStatus.Pending.rawValue
                rManager.realm.add(entity, update: true)
            }
        } catch {
            store.dispatch(RequestAction.Error(err: RequestError.CouldNotWrite, uuid: uuid))
            return nil
        }
        child.setValue(entity.toJSON(), withCompletionBlock: { err, _ in
            do {
                try rManager.realm.write {
                    let hasError = err != nil
                    entity.status = hasError ? MessageStatus.Failed.rawValue : MessageStatus.Sent.rawValue
                    store.dispatch(RequestAction.Done(uuid: uuid))
                }
            } catch {
                store.dispatch(RequestAction.Error(err: RequestError.CouldNotWrite, uuid: uuid))
            }
        })
        return nil
    }
}

private func _messageReceived(snapshot: DataSnapshot, uuid: String) {
    do {
        if !snapshot.exists() { throw RequestError.NotFound }
        guard let json = snapshot.value as? NSDictionary else { throw RequestError.NotJson }
        json.setValue(snapshot.key, forKey: "id")
        json.setValue(Date(json["timestamp"] as! Int), forKey: "timestamp")
        json.setValue(1, forKey: "status")
        let localMsg = rManager.realm.objects(MessageEntity.self).first(where: { $0.id == snapshot.key})
        json.setValue(localMsg?.status ?? MessageStatus.Sent.rawValue, forKey: "status")
        let entity = MessageEntity(value: json)
        rManager.save(objs: entity)
        store.dispatch(RequestAction.Done(uuid: uuid))
    } catch let err {
        store.dispatch(RequestAction.Error(err: err as! RequestError, uuid: uuid))
    }
}

private func _messagesReceived(snapshot: DataSnapshot, uuid: String) {
    do {
        if !snapshot.exists() { throw RequestError.NotFound }
        guard let json = snapshot.value as? NSDictionary else { throw RequestError.NotJson }
        var entities = [MessageEntity]()
        json.forEach({ (key, value) in
            let dic = value as! NSDictionary
            dic.setValue(snapshot.key, forKey: "id")
            dic.setValue(Date(dic["timestamp"] as! Int), forKey: "timestamp")
            dic.setValue(true, forKey: "sent")
            entities.append(MessageEntity(value: dic))
        })
        rManager.saveObjects(objs: entities)
        store.dispatch(RequestAction.Done(uuid: uuid))
    } catch let err {
        store.dispatch(RequestAction.Error(err: err as! RequestError, uuid: uuid))
    }
}
