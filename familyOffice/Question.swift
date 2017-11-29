//
//  Question.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/25/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase

struct Question{
    static let qKey = "id"
    static let qQuestionKey = "question"
    static let qAnswerKey = "answer"
    static let qSubjectKey = "subject"
    static let qDateKey = "date"
    static let qIsPrivateKey = "isPrivate"
    
    var id: String?
    var question: String!
    var answer: String?
    var subject: String!
    var date: String?
    var isPrivate: Bool
    
    init(question: String, answer: String,subject: String, date: String, isPrivate: Bool){
        self.question = question
        self.answer = answer
        self.subject = subject
        self.date = date
        self.isPrivate = isPrivate
        self.id = Constants.FirDatabase.REF.childByAutoId().key
    }
    
    init(snapshot: DataSnapshot){
        let dic = snapshot.value as! NSDictionary
        self.id = snapshot.key
        self.question = service.UTILITY_SERVICE.exist(field: Question.qQuestionKey, dictionary: dic)
        self.answer = service.UTILITY_SERVICE.exist(field: Question.qAnswerKey, dictionary: dic)
        self.subject = service.UTILITY_SERVICE.exist(field: Question.qSubjectKey, dictionary: dic)
        self.date = service.UTILITY_SERVICE.exist(field: Question.qDateKey, dictionary: dic)
        self.isPrivate = service.UTILITY_SERVICE.exist(field: Question.qIsPrivateKey, dictionary: dic)
    }
    
    func toDictionary() -> NSDictionary {
        return[
            Question.qQuestionKey: self.question,
            Question.qAnswerKey: self.answer ?? "",
            Question.qSubjectKey: self.subject,
            Question.qDateKey: self.date ?? "",
            Question.qIsPrivateKey: self.isPrivate,
        ]
    }
}
