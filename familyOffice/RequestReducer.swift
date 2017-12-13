//
//  RequestReducer.swift
//  familyOffice
//
//  Created by Nan Montaño on 07/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

func requestReducer(action: Action, state: RequestState?) -> RequestState {
    var state = RequestState(requests: state?.requests ?? [:])
    switch action {
    case RequestAction.Loading(let uuid):
        state.requests[uuid] = .loading
        break
    case RequestAction.Done(let uuid):
        state.requests[uuid] = .finished
        break
    case RequestAction.Error(let err, let uuid):
        state.requests[uuid] = .Failed(err)
    default:
        break
    }
    return state
}
