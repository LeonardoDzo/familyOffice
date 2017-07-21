
//
//  HandleMenuBar.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
protocol HandleMenuBar : class {
    func scrollMenuIndex(_ menuIndex: Int) -> Void
}
protocol HandleFamilySelected : class {
    func selectFamily() -> Void
}
protocol DateProtocol: class {
    func selectedDate(date: Date) -> Void
}
protocol ContactsProtocol: class {
    var users : [User]! {get set}
    func selected(users: [User]) -> Void
}
