//
//  AppState.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

struct AppState: StateType {
    var routingState: RoutingState
    var authState: AuthState
    var UserState: UserState
    var GoalsState : GoalState
    var FamilyState: FamilyState
    var EventState: EventState
    var GalleryState: GalleryState
    var ToDoListState: ToDoListState
    var ContactState: ContactState
    var MedicineState: MedicineState
    var IllnessState: IllnessState
    var FaqState: FaqState
    var safeBoxState: SafeBoxState
    var requestState: RequestState
    var insuranceState: InsuranceState
    
    var notifications = [NotificationModel]()
}
enum Result<T> {
    
    case loading
    case Loading(T)
    case failed
    case Failed(T)
    case finished
    case Finished(T)
    case noFamilies
    case none
}
extension Result : description {
}

extension Result {
    func status() -> Void {
        guard let topController = UIApplication.topViewController() else {
            return
        }
        topController.view.hideToastActivity()
        switch self {
        case .loading, .Loading(_):
            topController.view.makeToastActivity(.center)
            break
        case .failed, .Failed(_):
            topController.view.makeToast("Hubo algun error", duration: 2.0, position: .top)
            break
        case .finished, .Finished(_):
            break
        case .noFamilies:
            break
        case .none:
            break
        }
    }
}


func ==<T>(lhs: Result<T>, rhs: Result<T>) -> Bool where T: Equatable {
    switch (lhs, rhs) {
    case (.loading, .loading),
         (.failed, .failed),
         (.finished, .finished),
         (.noFamilies, .noFamilies),
         (.none, .none):
        return true
    case let (.Loading(a), .Loading(b)):
        return a == b
    case let (.Failed(a), .Failed(b)):
        return a == b
    default: return false
    }
}

func !=<T>(lhs: Result<T>, rhs: Result<T>) -> Bool where T: Equatable {
    return !(lhs == rhs)
}
