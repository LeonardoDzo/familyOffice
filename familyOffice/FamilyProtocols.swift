
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
    var users : [UserEntity]! {get set}
    func selected(users: [UserEntity]) -> Void
}
protocol repeatProtocol {
    var frequency : Frequency! {get set}
    var interval: Int? {get set}
    var end : Int? {get set}
    var days : String? {get set}
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
            return "Nunca"
        }
    }
    var value : Int? {
        switch self {
        case .daily:
            return 60*60*24
        case .weekly:
            return 60*60*24*7
        case .monthly:
            return 60*60*24*30
        case .year:
            return 60*60*24*365
        default:
            return nil
        }
    }
    
    
}
extension Frequency : Codable {
    enum CodingKeys: Int, CodingKey {
        case never, daily, weekly, monthly, year
    }
}
