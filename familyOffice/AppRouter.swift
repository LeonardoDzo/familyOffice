//
//  AppRouter.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import ReSwift
enum StoryBoard: String {
    case main = "Main",
    contacts = "Contacts",
    budget = "Budget",
    chat = "Chat",
    gallery = "Gallery",
    calendar = "Calendar",
    safeBox = "Safebox",
    families = "Families",
    setting = "Settings",
    health = "Health",
    toDoList = "ToDoList"
}

enum RoutingDestination: String {
    case start = "StartViewController"
    case signUp = "SingUpViewController"
    case preHome = "NavPreHome"
    case registerFamily = "RegisterFamilyView",
         homeSocial = "TabBarControllerView",
         profileFamily = "FamilyViewController",
         families = "FamilyCollectionViewController",
         contacts = "ContactsViewController",
         addEvent = "addEventTableViewController"
    case none = ""
}
extension RoutingDestination {
    func getStoryBoard() -> String {
        switch self {
        case .start, .signUp, .preHome, .homeSocial, .none:
            return StoryBoard.main.rawValue
        case .registerFamily,.profileFamily,.families,.contacts:
            return StoryBoard.families.rawValue
        case .addEvent:
            return StoryBoard.calendar.rawValue
        }
    }
}