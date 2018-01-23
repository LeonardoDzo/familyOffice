//
//  File.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import Stevia
class RequestAssistantCell: UITableViewCellX {
    var assistant: AssistantEntity!
    var titleLbl = UILabelX()
    var photo = UIImageViewX()
    var phoneLbl = UILabelX()
    var requestBtn : UIButtonX!  = UIButtonX()
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder)}
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func render() {
        sv(
            titleLbl,
            phoneLbl,
            requestBtn,
            photo
            
        )
        
        layout(
            10,
            |-photo.width(40).height(40)-titleLbl.width(80%),
            2,
            |-10-phoneLbl.width(100%),
            0,
            requestBtn.height(30).width(30%)-5-|,
            2
        )
        photo.loadImage(urlString: assistant.photoURL)
 
        titleLbl.text = assistant.name
        phoneLbl.text = assistant.phone
        requestBtn.setTitle("Petición", for: .normal)
        self.animation = "slideUp"
        self.animate()
       
        self.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.5137254902, blue: 0.3529411765, alpha: 1)
        
        titleLbl.style(self.labelsStyles)
        phoneLbl.style(self.labelsStyles)
        requestBtn.style(self.btnStyles)
        requestBtn.addTarget(self, action: #selector(self.request), for: .touchUpInside)
    }
    @objc func request() -> Void {
        Constants.FirDatabase.REF.child("assistants/\(assistant.id)/solicitudes/").setValue(["\((getUser()?.id)!)":true])
        self.makeToast("Solicitud enviada")
    }
    func labelsStyles(_ lbl: UILabelX) -> Void {
        lbl.textAlignment = .left
        lbl.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
    }
    
    func btnStyles(_ btn: UIButtonX) -> Void {
       btn.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
       btn.cornerRadius = 4
       btn.setImage(#imageLiteral(resourceName: "icons8-send_hot_list").maskWithColor(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), for: .normal)
       btn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
       btn.imageEdgeInsets = UIEdgeInsets(top: 6,left: 100,bottom: 6,right: 14)
       btn.titleEdgeInsets = UIEdgeInsets(top: 0,left: -50,bottom: 0,right: 34)
       
    }
    
}
