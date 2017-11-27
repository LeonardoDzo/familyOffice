//
//  UserState.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import Foundation
import ReSwift

struct UserState {
    var users : Result<Any>
    var user: Result<Any> = .none
    
    func getUser() -> User?  {
        if case .Finished(let value as User) = user {
            return value
        }
        return nil
    }
    func getUsers() -> [User]  {
        if case .Finished(let value as [User]) = users {
            return value
        }
        return []
    }
    
    func findUser(byId id: String) -> User? {
        var user: User!
        if case .Finished(let value as [User]) = self.users {
            user = value.first(where: {$0.id == id})
        }
        if case .Finished(let value as User) = self.user {
            user = value
        }
        return user
    }
}


