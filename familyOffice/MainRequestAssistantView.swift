//
//  MainRequestAssistantView.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import Stevia
class RequestAssistantMainView : UIViewX {
    let requestTable = RequestTableview()
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
           requestTable
        )
        layout(
            0,
            |-0-requestTable.width(100%).height(100%)-0-|,
            0)
        // Vertical + Horizontal Layout in one pass
        // With type-safe visual format
        requestTable.refreshData()
        backgroundColor = #colorLiteral(red: 0.9792956669, green: 0.9908331388, blue: 1, alpha: 1)
    }
}
