//
//  SafeBoxReducer.swift
//  familyOffice
//
//  Created by Developer on 8/16/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder
import Firebase

struct SafeBoxReducer: Reducer {
    
    func handleAction(action: Action, state: SafeBoxState?) -> SafeBoxState {
        var state = state ?? SafeBoxState(safeBoxFiles: [:], status: .none)
        switch action {
        case let action as InsertSafeBoxFileAction:
            if action.safeBoxFile == nil{
                return state
            }
            insertSafeBoxFile(action.safeBoxFile)
            state.status = .loading
            
        case let action as UpdateSafeBoxFileAction:
            if action.safeBoxFile == nil{
                return state
            }
            updateSafeBoxFile(action.safeBoxFile)
            state.status = .loading
            return state
        case let action as DeleteSafeBoxFileAction:
            if action.safeBoxFile == nil{
                return state
            }
            deleteSafeBoxFile(action.safeBoxFile)
            state.status = .loading
            return state
        default:break
        }
        return state
    }
    
    func insertSafeBoxFile(_ item: SafeBoxFile) -> Void {
        let id = store.state.UserState.user?.id!
        let path = "safebox/\(id!)/\(item.id!)"
        service.SAFEBOX_SERVICE.insert(path, value: item.toDictionary(), callback: {ref in
            if ref is FIRDatabaseReference{
//                store.state.safeBoxState.safeBoxFiles[id!]?.append(item)
                store.state.safeBoxState.status = .finished
            }
        })
    }
    
    func updateSafeBoxFile(_ item: SafeBoxFile) -> Void {
        let id = store.state.UserState.user?.id!
        let path = "safebox/\(id!)/\(item.id!)"
        service.SAFEBOX_SERVICE.update(path, value: item.toDictionary() as! [AnyHashable : Any], callback: { ref in
            if ref is FIRDatabaseReference {
                if let index = store.state.safeBoxState.safeBoxFiles[id!]?.index(where: {$0.id! == item.id! }){
                    store.state.safeBoxState.safeBoxFiles[id!]?[index] = item
                    store.state.safeBoxState.status = .finished
                }
                
            }
            
        })
    }
    
    func deleteSafeBoxFile(_ item: SafeBoxFile) -> Void {
        let id = store.state.UserState.user?.id!
        let path = "safebox/\(id!)/\(item.id!)"
        service.SAFEBOX_SERVICE.delete(path) { (Any) in
            if let index = store.state.safeBoxState.safeBoxFiles[id!]?.index(where: {$0.id! == item.id! }){
                store.state.safeBoxState.safeBoxFiles[id!]?.remove(at: index)
                store.state.safeBoxState.status = .finished
            }
        }
    }

}
