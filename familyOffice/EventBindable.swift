//
//  File.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 12/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import UIKit
protocol EventEBindable: AnyObject, bind {
    var event: EventEntity! {get set}
    var backgroundType : UIImageViewX! {get}
    var dateLbl: UILabel! {get}
    var hourLbl: UILabel! {get}
    var titleLbl : UILabel! {get}
    var detailsTxtV: UITextView! {get}
    var detailsLbl: UILabel! {get}
    var addressLbl: UILabel! {get}
}
extension EventEBindable  {
    
    var dateLbl: UILabel! {return nil}
    var backgroundType : UIImageViewX! {return nil}
    var hourLbl: UILabel! {return nil}
    var titleLbl : UILabel! {return nil}
    var detailsLbl: UILabel! {return nil}
    var detailsTxtV: UITextView! {return nil}
    var addressLbl: UILabel! {return nil}
    
    func bind(sender: Any?) {
        if sender is EventEntity {
            self.event = sender as! EventEntity
            bind()
        }
    }
    func bind(){
        guard let event = self.event else { return }
        
        if let titleLbl = self.titleLbl {
            titleLbl.text = !event.title.isEmpty ? event.title : event.father?.title ?? "Sin título"
        }
        if let dateLbl = self.dateLbl {
            let start = Date(event.startdate)?.string(with: .ddMMMyyyy)
            let end = Date(event.enddate)?.string(with: .ddMMMyyyy)
            if start == end {
                dateLbl.text =  "\(Date(event.startdate)!.string(with: .MMMddHHmm)) - \(Date(event.enddate)!.string(with: .hourAndDate))"
            }else{
                dateLbl.text =  "\(Date(event.startdate)!.string(with: .MMMddHHmm)) - \(Date(event.enddate)!.string(with: .MMMddHHmm))"
            }
        }
        if let detailLbl = self.detailsLbl {
            detailLbl.text = event.details ??  event.father?.details ?? "Sin detalles"
        }
        if let detailTxV =  self.detailsTxtV {
            detailTxV.text = event.details ??  event.father?.details ?? "Sin detalles"
        }
        if let hourLbl = self.hourLbl {
            let start = Date(event.startdate)?.string(with: .ddMMMyyyy)
            let end = Date(event.enddate)?.string(with: .ddMMMyyyy)
            if start == end {
                hourLbl.text =  "\(Date(event.startdate)!.string(with: .hourAndDate)) - \(Date(event.enddate)!.string(with: .hourAndDate))"
            }else{
                hourLbl.text =  "\(Date(event.startdate)!.string(with: .hourAndDate)) - \(Date(event.enddate)!.string(with: .MMMddHHmm))"
            }
        }
        if let AddressLbl = self.addressLbl {
            var locationString = "No se especificó ubicación"
            if event.location != nil, let location = event.location?.title {
                locationString = location
            }else if event.father?.location != nil, let location = event.father?.location?.title {
                locationString = location
            }
            AddressLbl.text =  locationString
        }
        if let backgroundView = self.backgroundType {
            var type = self.event.eventtype
            switch type{
            case .Meet:
                backgroundView.image = #imageLiteral(resourceName: "busines-sbackground")
                break
            case .BirthDay:
                backgroundView.image = #imageLiteral(resourceName: "background_birthday")
                break
            default:
                backgroundView.image = #imageLiteral(resourceName: "background_events")
                break
            }
        }
    }
}
