//
//  AssistantViewStevia.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 16/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import Stevia

class MenuMainAss: UIViewX {
    let allBtn = UIButtonX()
    let line = UIViewX()
    let doneBtn = UIButtonX()
    let pendingBtn = UIButtonX()
    var selected = 0
    convenience init() {
        self.init(frame:.zero)
        // This is only needed for live reload as injectionForXcode
        // doesn't swizzle init methods.
        // Get injectionForXcode here : http://johnholdsworth.com/injection.html
        render()
    }
    
    fileprivate func setStyleBtns() {
        allBtn.style(commonFieldStyle)
        pendingBtn.style(commonFieldStyle)
        doneBtn.style(commonFieldStyle)
    }
    
    func render() {
        // View Hierarchy
        // This essentially does `translatesAutoresizingMaskIntoConstraints = false`
        // and `addSubsview()`. The neat benefit is that
        // (`sv` calls can be nested which will visually show hierarchy ! )
        sv(
            allBtn,
            doneBtn,
            pendingBtn,
            line
        )
      
        layout(
            4,
            |-allBtn.width(33%)-doneBtn.width(33%)-pendingBtn.width(33%)-| ~ 60,
            2,
            |-line-| ~ 5,
            2
        )
        alignHorizontally(allBtn,doneBtn,pendingBtn)
        line.width(120)
        line.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        line.cornerRadius = 2
        allBtn.tag = 0
        doneBtn.tag = 1
        doneBtn.centerHorizontally()
        pendingBtn.tag = 2
        // Content 🖋
        allBtn.text("Todas")
        doneBtn.text("Terminadas")
        pendingBtn.text("Pendientes")
        
        setStyleBtns()
    }
    
    func indexLine(from: Int, to: Int) -> Void {
        selected = to
        line.animation = to >= from ? "slideRight" : "slideLeft"
        line.frame.origin.x = self.bounds.size.width/3 * CGFloat(to) + 8
        setStyleBtns()
        line.animate()
    }
    
    // Style can be extracted and applied kind of like css \o/
    // but in pure Swift though!
    func commonFieldStyle(_ f:UIButtonX) {
        f.cornerRadius = 6
    
        f.clipsToBounds = true
        
        f.setTitleColor(f.tag == selected ? #colorLiteral(red: 0.9529411765, green: 0.5137254902, blue: 0.3529411765, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .normal)
        f.contentHorizontalAlignment = .center
        f.contentVerticalAlignment = .fill
        f.isEnabled = true
        
        f.popIn = true
    }
    
}

