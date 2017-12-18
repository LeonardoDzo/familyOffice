//
//  SignUPViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 15/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Eureka
import Toast_Swift
import ReSwift

class SignUPViewController: FormViewController {
    var user = UserEntity()
    var pass = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let savebtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.validate))
        self.setupBack()
        self.navigationItem.rightBarButtonItem = savebtn
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
            +++ Section("Información de Contacto")
            <<< EmailRow() { row in
                row.title = "Email"
                row.placeholder = "Email"
                row.value = user.email
                row.add(rule: RuleRequired())
                row.add(rule: RuleEmail())
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else{
                        try! rManager.realm.write {
                            self.user.email = row.value ?? ""
                        }
                    }
            }
            <<< PasswordRow() { row in
                row.title = "Contraseña Nueva"
                row.placeholder = ""
                row.add(rule: RuleRequired())
                row.add(rule: RuleMinLength(minLength: 6, msg: "Mínimo 6 letras."))
                row.validationOptions = .validatesOnChange
                row.tag = "newPass"
                }.onChange({ (row) in
                    self.pass = row.value ?? ""
                }).cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< PasswordRow() { row in
                row.title = "Repetir contraseña"
                row.placeholder = ""
                row.add(rule: RuleRequired())
                row.add(rule: RuleMinLength(minLength: 6, msg: "Mínimo 6 letras."))
                row.validationOptions = .validatesOnChange
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }else{
                        let xrow: TextRow? = self.form.rowBy(tag: "newPass")
                        if row.value != xrow?.value {
                            cell.titleLabel?.textColor = .red
                        }
                    }
            }
            
  
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self ){
            $0.select({ s in
                s.authState
            })
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    @objc func validate(){
        let errors = form.validate()
        
        if errors.count == 0  {
            if !pass.isEmpty {
                store.dispatch(AuthSvc(.registerUser(user: self.user, pass: pass)))
            }
            
        } else {
            let t = ToastStyle()
            self.view.makeToast("\(errors.description)", duration: 5.0, point: self.view.center, title: "Errores", image: nil, style: t, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
extension SignUPViewController : StoreSubscriber{
    typealias StoreSubscriberStateType = AuthState
    func newState(state: AuthState) {
        switch state.state {
        case .Finished(let action as AuthAction):
            if case AuthAction.registerUser(_, _) = action {
                self.back3()
            }
        case .Failed(_), .failed:
            self.view.makeToast("Algo sucedio mal, intentelo mas tarde!")
            break
        default:
            break
        }
    }
}
