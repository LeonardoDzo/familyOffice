//
//  UserPersonalFormViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 24/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import ReSwift

class UserPersonalFormViewController: FormViewController {
    var user : UserEntity!
    override func viewDidLoad() {
        super.viewDidLoad()
        user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: Auth.auth().currentUser?.uid)
        let addbtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.update))
      
    
        self.setupBack()
        self.navigationItem.rightBarButtonItem = addbtn
        
        
        form +++ Section("Información Básica")
            
            <<< TextRow() { row in
                row.title = "Nombre"
                row.placeholder = "Mi nombre"
                row.add(rule: RuleRequired())
                row.add(rule: RuleMinLength(minLength: 5, msg: "Mínimo 4 letras."))
                row.add(rule: RuleMaxLength(maxLength: 20, msg: "Máximo 20 letras."))
                row.validationOptions = .validatesOnChange
                row.value = user.name
                row.tag = "name"
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else{
                        try! rManager.realm.write {
                            self.user.name = row.value!
                        }
                        
                    }
            }
            
            <<< PhoneRow() { row in
                row.title = "Télefono"
                row.placeholder = "Mi télefono"
                row.value = user.phone
                row.add(rule: RuleRequired())
                row.add(rule: RuleExactLength(exactLength: 10))
                row.tag = "phone"
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else{
                        try! rManager.realm.write {
                            self.user.phone = row.value ?? ""
                        }
                    }
            }
        
      +++  Section("Información Personal")
            
            <<< TextRow() { row in
                row.title = "RFC"
                row.placeholder = "RFC"
                row.value = user.rfc
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else{
                         try! rManager.realm.write {
                            self.user.rfc = row.value ?? ""
                         }
                    }
            }
            
            <<< TextRow() { row in
                row.title = "NSS"
                row.placeholder = "Número de seguro social"
                row.value = user.nss
                row.add(rule: RuleExactLength(exactLength: 11))
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else{
                        try! rManager.realm.write {
                            self.user.nss = row.value ?? ""
                        }
                    }
            }
            <<< TextRow() { row in
                row.title = "Curp"
                row.placeholder = "Curp"
                row.value = user.curp
                row.add(rule: RuleExactLength(exactLength: 18))
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else{
                        try! rManager.realm.write {
                            self.user.curp = row.value ?? ""
                        }
                    }
            }
            <<< DateRow() { row in
                row.title = "Cumpleaños"
                if let dateint = Int(user.birthday) {
                    row.value = Date(timeIntervalSince1970: TimeInterval(dateint/1000))
                }
                }.cellUpdate { cell, row in
                    if row.isValid {
                        try! rManager.realm.write {
                            if let date = row.value
                            {
                                self.user.birthday = String(date.toMillis()!)
                            }
                            
                        }
                    }
            }
            <<< TextRow() { row in
                row.title = "Dirección"
                row.placeholder = "Dirección"
                row.value = user.address
                }.onChange({ (value) in
                    if value.isValid {
                        try! rManager.realm.write {
                            self.user.address = value.value ?? ""
                        }
                    }
                })
            <<< PushRow<String>() { row in
                row.title = "Tipo de Sangre"
                row.options = ["A+","A-","O+","O-","B+","B-","AB+","AB-"]
                row.value = user.bloodtype
                row.selectorTitle = "Escoge un tipo de sangre"
                }.onChange({ (row) in
                    if row.isValid {
                        try! rManager.realm.write {
                            self.user.bloodtype = row.value ?? ""
                            row.updateCell()
                        }
                    }
                }).onPresent({ (form, to) in
                    to.dismissOnSelection = true
                    to.dismissOnChange = false
                })
        
        +++ Section("Caja fuerte")
            <<< TextRow() { row in
                row.title = "Contraseña"
                row.placeholder = "RFC"
                row.value = "123456"
                
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else{
                        try! rManager.realm.write {
                            self.user.rfc = row.value ?? ""
                        }
                    }
        }
        
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        // Enables smooth scrolling on navigation to off-screen rows
        animateScroll = true
        // Leaves 20pt of space between the keyboard and the highlighted row after scrolling to an off screen row
        rowKeyboardSpacing = 20
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func update() -> Void {
        if user.name.isEmpty || user.phone.isEmpty {
            self.view.makeToast("Vérifique los campos del nombre/télefono", duration: 3.0, position: .center)
        }else{
            store.dispatch(UserS(.update(user: self.user, img: nil)))
        }
        
    }
    

}
extension UserPersonalFormViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = UserState
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            $0.select({ (s) in
                s.UserState
            })
        }
    }
    func newState(state: UserState) {
        self.view.hideToastActivity()
        switch state.user {
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .Finished( _ as UserAction):
            self.view.makeToast("Datos Actualizados", duration: 4.0, position: .bottom)
            break
        case .Failed( _ as UserAction):
            self.view.makeToast("Sucedio un error", duration: 2.0, position: .bottom)
            break
        default:
            break
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
}
