//
//  TopViewProfileAssistant.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 18/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import Stevia
class ProfileAssistantStevia: UIViewX {
    let topview = TopViewProfileAssistant()
    convenience init() {
        self.init(frame:CGRect.zero)
        // This is only needed for live reload as injectionForXcode
        // doesn't swizzle init methods.
        // Get injectionForXcode here : http://johnholdsworth.com/injection.html
        render()
    }
    
    func render() {
        
        // View Hierarchy
        // This essentially does `translatesAutoresizingMaskIntoConstraints = false`
        // and `addSubsview()`. The neat benefit is that
        // (`sv` calls can be nested which will visually show hierarchy ! )
        sv(
            topview
        )
        layout(
            0,
            |topview.width(100%)| ~ 300
        )
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
       
    }
}
