//
//  References.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 01/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

func ref_users(uid: String) -> String {
    return "users/\(uid)"
}

func ref_family(_ fid: String) -> String {
    return  "families/\(fid)"
}

func ref_events(_ eid: String) -> String {
    return  "events/\(eid)"
}

func ref_pending(_ pending: PendingEntity) -> String {
    return  "pendings/\(pending.assistantId)/\(pending.id)"
}
