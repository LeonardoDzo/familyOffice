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
    toDoList = "ToDoList",
    firstaid = "FirstAidKit"
}

enum RoutingDestination: String {
    case start = "StartViewController"
    case signUp = "SingUPViewController"
    case homeSocial = "TabBarControllerView",
         profileFamily = "FamilyProfileViewController",
         families = "FamilyCollectionViewController",
         contacts = "ContactsViewController",
         addEvent = "EventViewController",
         prehome = "PreHomeViewController",
         confView = "ConfiguracionesView",
         personalData = "SetPersonalDataViewController",
         profileView = "ProfileUserViewController",
         mainCalendar = "mainnavCalendar",
         eventDetails = "EventDetailsViewController"
    
    // first aid
    case illness = "IllnessTableViewController",
         addIllness = "NewIllnessFormController"
    case none = ""
}
extension RoutingDestination {


    func getStoryBoard() -> String {
        switch self {
        case .start, .signUp, .homeSocial, .none, .prehome:
            return StoryBoard.main.rawValue
        case .profileFamily,.families,.contacts, .profileView:
            return StoryBoard.families.rawValue
        case .personalData, .confView:
            return StoryBoard.setting.rawValue
        case .addEvent,.mainCalendar, .eventDetails:
            return StoryBoard.calendar.rawValue
        case .illness, .addIllness:
            return StoryBoard.firstaid.rawValue
        }
    }
    
    
}
