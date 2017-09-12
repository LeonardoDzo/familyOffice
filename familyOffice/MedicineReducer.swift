//
//  MedicineReducer.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/20/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Firebase

struct MedicineReducer {
    func handleAction(action: Action, state: MedicineState?) -> MedicineState {
        var state = state ?? MedicineState(medicines: [:], status: .none)
        switch action {
        case let action as InsertMedicineAction:
            if action.medicine == nil{
                return state
            }
            insertMedicine(action.medicine)
            state.status = .loading
            return state
        case let action as UpdateMedicineAction:
            if action.medicine == nil{
                return state
            }
            updateMedicine(action.medicine)
            state.status = .loading
            return state
        case let action as DeleteMedicineAction:
            if action.medicine == nil{
                return state
            }
            deleteMedicine(action.medicine)
            state.status = .loading
            return state
        default:
            break
        }
        return state
    }
    
    func insertMedicine(_ medicine: Medicine) -> Void {
        let id = store.state.UserState.user?.familyActive!
        let path = "medicines/\(id!)/\(medicine.id!)"
        service.MEDICINE_SERVICE.insert(path, value: medicine.toDictionary(), callback: {ref in
            if ref is DatabaseReference {
                store.state.MedicineState.medicines[id!]?.append(medicine)
                store.state.MedicineState.status = .finished
            }
        })
    }
    
    func updateMedicine(_ medicine: Medicine) -> Void {
        let id = store.state.UserState.user?.familyActive!
        let path = "medicines/\(id!)/\(medicine.id!)"
        service.MEDICINE_SERVICE.update(path, value: medicine.toDictionary() as! [AnyHashable:Any]) { ref in
            if ref is DatabaseReference {
                if let index = store.state.MedicineState.medicines[id!]?.index(where: {$0.id! == medicine.id!}){
                    store.state.MedicineState.medicines[id!]?[index] = medicine
                    store.state.MedicineState.status = .finished
                }
            }
        }
    }
    
    func deleteMedicine(_ medicine: Medicine) -> Void {
        let id = store.state.UserState.user?.familyActive!
        let path = "medicines/\(id!)/\(medicine.id!)"
        service.MEDICINE_SERVICE.delete(path) { (Any) in
            if let index = store.state.MedicineState.medicines[id!]?.index(where: {$0.id! == medicine.id!}){
                store.state.MedicineState.medicines[id!]?.remove(at: index)
                store.state.MedicineState.status = .finished
            }
        }
    }
}
