
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
    var frequency : Frequency! {get set}
   
    var days : [String]! {get set}
}

protocol repeatTypeEvent: repeatProtocol {
    var interval: Int! {get set}
    var end : Int! {get set}
}

protocol GDL90_Enum  {
    var description: String { get }
}
enum Frequency: Int, GDL90_Enum  {
    case never
    case daily
    case weekly
    case monthly
    case year
    
    var description: String {
        switch self {
        case .daily:
            return "Diario"
        case .weekly:
            return "Semanal"
        case .monthly:
            return "Mensual"
        case .year:
            return "Anual"
        default:
            return "nunca"
        }
    }
    
    
}
