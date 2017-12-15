//
//  DatesModel.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 23/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase

public enum EventAvailability : Int {
    
    
    case notSupported
    
    case busy
    
    case free
    
    case tentative
    
    case unavailable
}

public enum Priority: Int, Codable {
    case Baja,
    Media,
    Alta
}

public enum EventStatus : Int, Codable {
    
    
    case none
    
    case confirmed
    
    case tentative
    
    case canceled
}

enum eventType: Int, GDL90_Enum, Codable  {

    case Default = 0, BirthDay, Meet
    var description: String {
        switch self {
        case .BirthDay:
            return "Cumpleaños"
        case .Meet:
            return "Reunion"
        default:
            return "Default"
        }
    }
}

protocol EventBindable: AnyObject, bind {
    
    var event: EventEntity! { get set }
    
    var descriptionLabel: UILabel! {get}
    var startDateLbl: UILabel! {get}
    var endDateLbl: UILabel! {get}
    var locationLabel: UILabel! {get}
    var titleLabel: UILabel! {get}
    var titleTxtField: UITextField! {get}
    var imageTime : UIImageView! {get}
    var ubicationLabel: UITextField! {get}
    var repeatLabel: UILabel! {get}
    var endRepeat: UILabel! {get}
    var descriptionTxtField: UITextField! {get}
    var typeLbl: UILabel! {get}
    var memberCountLbl: UILabel! {get}
}

extension EventBindable  {
    // Make the views optionals
   
    var startDateLbl: UILabel! {return nil}
    var endDateLbl: UILabel! {return nil}
    var typeLbl: UILabel! {return nil}
    var memberCountLbl: UILabel! {return nil}
    var locationLabel: UILabel! {return nil}
    var titleLabel: UILabel! {return nil}
    var descriptionLabel: UILabel! {return nil}
    var descriptionTxtField: UITextField! {return nil}
    var imageTime: UIImageView! {return nil}
    var ubicationLabel: UITextField! {return nil}
    var repeatLabel: UILabel! {return nil}
    var endRepeat: UILabel! {return nil}
    var titleTxtField: UITextField! {return nil}
    
    // Bind
    
    func bind(sender: Any?) {
        if sender is EventEntity {
            bind(event: sender as! EventEntity)
        }
    }
    
    func bind(event: EventEntity) {
        self.event = event
        bind()
    }
    
    func bind() {
        
        guard let event = self.event else {
            return
        }
        
        if let locationLabel = self.locationLabel {
//            if event.location != nil {
//                locationLabel.text =  (event.location?.title.isEmpty)! ?  "Sin ubicación" : "\(event.location?.title ?? ""), \(event.location?.subtitle ?? "")"
//            }else{
//                locationLabel.text =   "Sin ubicación"
//            }
            
        }
        if let ubicationLabel = self.ubicationLabel {
//            if event.location != nil {
//                ubicationLabel.text =  (event.location?.title.isEmpty)! ?  "Sin ubicación" : "\(event.location?.title ?? ""), \(event.location?.subtitle ?? "")"
//            }else{
//                ubicationLabel.text =   "Sin ubicación"
//            }
            
        }
        if let endDateLbl = self.endDateLbl {
            var formatter: DateFormatter!
            if event.isAllDay ?? false {
                formatter = .dayMonthAndYear
            }else{
                formatter = .dayMonthYearHourMinute
            }
            
            let date = Date(timeIntervalSince1970: TimeInterval(event.enddate/1000))
           
            endDateLbl.text = date.string(with: formatter)
            
        }
        if let memberCountLbl = self.memberCountLbl {
            memberCountLbl.text = String(event.members.count)
        }
        if let titleTxtField = self.titleTxtField {
            titleTxtField.text = event.title
        }
        if let titleLabel = self.titleLabel {
            titleLabel.text = event.title
        }
        if let descriptionTxtField = self.descriptionTxtField {
            descriptionTxtField.text = event.description
        }
        if let descriptionLabel = self.descriptionLabel {
            descriptionLabel.text = event.description
        }
        if let typeLbl = self.typeLbl {
            typeLbl.text = event.type?.description
        }
        
        
        if let repeatLabel = self.repeatLabel {
            repeatLabel.text = event.repeatmodel?.frequency.description
        }

        
    }
}




