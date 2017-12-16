//
//  SignUPViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 15/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Eureka
class SignUPViewController: FormViewController {
    var user = UserEntity()
    override func viewDidLoad() {
        super.viewDidLoad()

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
                row.tag = "phone"
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
                }.cellUpdate { cell, row in
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
