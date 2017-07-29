
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
protocol repeatProtocol {
    var frequency : String! {get set}
    var each: Int! {get set}
    var days : [String]! {get set}
}

protocol repeatTypeEvent: repeatProtocol {
    var end : Int! {get set}
}

protocol GDL90_Enum  {
    var description: String { get }
}
enum REPEAT_TYPE: Int, GDL90_Enum  {
    case NEVER = 0
    case DAILY = 1
    case WEEKLY = 2
    case WEEKLY_2 = 3
    case MONTHLY = 4
    case YEAR = 5
    
    var description: String {
        switch self {
        case .DAILY:
            return "day"
        case .WEEKLY:
            return "week"
        case .WEEKLY_2:
            return "week"
        case .MONTHLY:
            return "month"
        case .YEAR:
            return "year"
        default:
            return ""
        }
    }
    
}
