//
//  TopViewProfileAssistant.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 18/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import Stevia

class TopViewProfileAssistant: UIViewX, UserEModelBindable {
    var userModel: UserEntity! = getUser()
    var profileImage: UIImageViewX! = UIImageViewX()
    var titleLbl: UILabel! = UILabel()
    
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
            profileImage,
            titleLbl
        )
        layout(
            70,
            profileImage.height(100).width(100),
            5,
            titleLbl,
            ""
        )
        self.bind()
        
        profileImage.centerHorizontally()
        profileImage.profileUser()
        profileImage.cornerRadius = 50
        profileImage.clipsToBounds = true
        titleLbl.centerHorizontally()
        titleLbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background_assistance"))
    }
}
