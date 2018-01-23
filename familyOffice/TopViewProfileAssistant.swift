//
//  TopViewProfileAssistant.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 18/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import Stevia

class TopViewProfileAssistant: UIViewX, AssistantBindable {
    var userModel: AssistantEntity!
    var profileImage: UIImageViewX! = UIImageViewX()
    var titleLbl: UILabel! = UILabel()
    var taskCompleteBtn: BtnWithLbl! = BtnWithLbl()
    var allTaskBtn: BtnWithLbl! = BtnWithLbl()
    var callBtn: BtnWithLbl! = BtnWithLbl()
    var phoneLbl: UILabel! = UILabel()
    
    convenience init() {
        self.init(frame:CGRect.zero)
        // This is only needed for live reload as injectionForXcode
        // doesn't swizzle init methods.
        // Get injectionForXcode here : http://johnholdsworth.com/injection.html
        if  let id = getUser()?.assistants.first?.key {
            self.userModel = rManager.realm.object(ofType: AssistantEntity.self, forPrimaryKey: id)
        }
        
        render()
    }
    
    fileprivate func setStyleImage(_ img: UIImageViewX) {
        img.centerHorizontally()
        img.profileUser()
        img.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        img.height(120).width(120)
        print( img.frame.width, img)
        img.cornerRadius = 60
        img.clipsToBounds = true
    }
    
    func render() {
        
        sv(
            profileImage,
            titleLbl,
            taskCompleteBtn,
            allTaskBtn,
            callBtn
        )
       
        layout(
            70,
            profileImage,
            5,
            titleLbl,
            10,
            |-30-allTaskBtn.width(30%)-60-taskCompleteBtn.width(30%)-60-callBtn.width(30%),
            ""
        )
        self.bind()
        taskCompleteBtn.centerHorizontally()
        profileImage.style(self.setStyleImage)
        titleLbl.centerHorizontally()
        titleLbl.font =  UIFont(name: "Roboto", size: 20)
        titleLbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
       
        
        refreshData()
        callBtn.setFeatures { view in
            view.btn.setImage(#imageLiteral(resourceName: "phone").maskWithColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))!, for: .normal)
            view.btn.style(self.setStyleBtn)
            view.lbl.text = "LLAMAR"
            
            view.lbl.style(self.setStyleLbl)
            view.btn.tag =  self.userModel != nil ? Int(self.userModel.phone ) ?? 0 : 0
        }
        backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background_assistance"))
    }
    
    func setStyleBtn(btn: UIButtonX) -> Void {
        btn.width(50).height(50)
        btn.cornerRadius = 25
        btn.clipsToBounds = true
        btn.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        btn.borderWidth = 2
        btn.titleLabel?.font = UIFont(name: "Roboto", size: 18)
    }
    func setStyleLbl(l: UILabelX) -> Void {
       l.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
       l.font = UIFont(name: "Roboto", size: 18)
       l.adjustsFontSizeToFitWidth = true
       l.minimumScaleFactor = 0.1
       l.numberOfLines = 1
    }
    func refreshData() -> Void {
         let pendings = rManager.realm.objects(PendingEntity.self)
        allTaskBtn.setFeatures { view in
            view.btn.setTitle("\(pendings.count)", for: .normal)
            view.btn.style(self.setStyleBtn)
            view.lbl.text = "TAREAS"
            view.lbl.style(self.setStyleLbl)
            
            
        }
        taskCompleteBtn.setFeatures { view in
            view.btn.setTitle("\(pendings.filter("done = %@",true).count)", for: .normal)
            view.btn.style(self.setStyleBtn)
            view.lbl.text = "COMPLETAS"
            view.lbl.style(self.setStyleLbl)
            
        }
        allTaskBtn.animation = "fadeIn"
        taskCompleteBtn.animation = "fadeIn"
        allTaskBtn.animate()
        taskCompleteBtn.animate()
    }
}
