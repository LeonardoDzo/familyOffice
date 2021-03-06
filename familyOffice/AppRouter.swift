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
    firstaid = "FirstAidKit",
    assistant = "Assistant"
}

enum RoutingDestination: String {
    case start = "StartViewController"
    case signUp = "SignUPViewController"
    case homeSocial = "TabBarControllerView",
         profileFamily = "FamilyProfileViewController",
         families = "FamilyCollectionViewController",
         contacts = "ContactsViewController",
         addEvent = "EventViewController",
         prehome = "PreHomeViewController",
         confView = "UserPersonalFormViewController",
         personalData = "SetPersonalDataViewController",
         profileView = "ProfileUserViewController",
         mainCalendar = "mainnavCalendar",
         eventDetails = "EventDetailsViewController",
         chat = "ChatGroupViewController",
         addEditPending = "AddEditPendingViewController",
         setSafeboxPwd = "SetSafeboxPassword",
         requestAssitant = "RequestForAsssistantViewController"
    
    // first aid
    case illness = "IllnessTableViewController",
         addIllness = "NewIllnessFormController"
    case none = ""
}
extension RoutingDestination {


    func getStoryBoard() -> String {
        switch self {
        case .start, .signUp, .homeSocial, .none, .prehome, .requestAssitant:
            return StoryBoard.main.rawValue
        case .profileFamily,.families,.contacts:
            return StoryBoard.families.rawValue
        case .personalData, .confView,  .profileView, .setSafeboxPwd:
            return StoryBoard.setting.rawValue
        case .addEvent,.mainCalendar, .eventDetails:
            return StoryBoard.calendar.rawValue
        case .illness, .addIllness:
            return StoryBoard.firstaid.rawValue
        case .chat:
            return StoryBoard.chat.rawValue
        case .addEditPending:
            return StoryBoard.assistant.rawValue
        }
    }
    
    
}
