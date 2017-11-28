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
    
    var GalleryState: GalleryState
    var ToDoListState: ToDoListState
    var ContactState: ContactState
    var MedicineState: MedicineState
    var IllnessState: IllnessState
    var FaqState: FaqState
    var safeBoxState: SafeBoxState

    
    var notifications = [NotificationModel]()
}
enum Result<T> {
    case loading
    case failed
    case Failed(T)
    case finished
    case Finished(T)
    case noFamilies
    case none
}
extension Result : description{
}

extension Result {
    func status() -> Void {
        guard let topController = UIApplication.topViewController() else {
            return
        }
        topController.view.hideToastActivity()
        switch self {
        case .loading:
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
