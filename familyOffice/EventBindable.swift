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
    var backgroundType : UIImageView! {get}
    var dateLbl: UILabel! {get}
    var hourLbl: UILabel! {get}
    var titleLbl : UILabel! {get}
    var detailsLbl: UILabel! {get}
}
extension EventEBindable  {
    
    var dateLbl: UILabel! {return nil}
    var backgroundType : UIImageView! {return nil}
    var hourLbl: UILabel! {return nil}
    var titleLbl : UILabel! {return nil}
    var detailsLbl: UILabel! {return nil}
    
    func bind(sender: Any?) {
        if sender is EventEntity {
            self.event = sender as! EventEntity
            bind()
        }
    }
    func bind(){
        guard let event = self.event else { return }
        
        if let titleLbl = self.titleLbl {
            titleLbl.text = event.title ?? "Sin titulo"
        }
        if let dateLbl = self.dateLbl {
            print(event)
            let start = Date(event.startdate)?.string(with: .ddMMMyyyy)
            let end = Date(event.enddate)?.string(with: .ddMMMyyyy)
            if start == end {
                dateLbl.text =  "\(Date(event.startdate)!.string(with: .MMMddHHmm)) - \(Date(event.enddate)!.string(with: .hourAndDate))"
            }else{
                dateLbl.text =  "\(Date(event.startdate)!.string(with: .MMMddHHmm)) - \(Date(event.enddate)!.string(with: .MMMddHHmm))"
            }
        }
        if let detailLbl = self.detailsLbl {
            detailLbl.text = event.details ?? "Sin detalles"
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
        if let backgroundView = self.backgroundType {
            if let type = self.event.eventtype {
                switch  type{
                case .Meet:
                    backgroundView.image = #imageLiteral(resourceName: "busines-sbackground")
                    break
                case .BirthDay:
                    backgroundView.image = #imageLiteral(resourceName: "background_birthday")
                    break
                default:
                    break
                }
            }
            
        }
    }
}
