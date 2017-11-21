//
//  Reducer.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

protocol Reducer {
    associatedtype StoreSubscriberStateType
    func handleAction(state: StoreSubscriberStateType?) -> StoreSubscriberStateType
}
