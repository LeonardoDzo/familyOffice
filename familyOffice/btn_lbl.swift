//
//  btn_lbl.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 19/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import Stevia

class BtnWithLbl: UIViewX {
    var btn : UIButtonX! = UIButtonX()
    var lbl: UILabelX! = UILabelX()
    
    convenience init() {
        self.init(frame:.zero)
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
            btn,
            lbl
        )
        
        layout(
            0,
            |btn|,
            2,
            |lbl.width(100%)|,
            2
        )
        btn.centerHorizontally()
        lbl.centerHorizontally()
    }
    
    func setFeatures(handler: @escaping ((BtnWithLbl)->Void)) {
        handler(self)
    }
}
