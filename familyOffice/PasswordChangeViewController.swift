//
//  PasswordChangeViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Eureka
class PasswordChangeViewController: FormViewController {

    
    override func viewDidLoad() {
        let doneButton = UIBarButtonItem(title: "Cambiar", style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.savePassword))
        self.navigationItem.rightBarButtonItem = doneButton
        super.viewDidLoad()
        form +++ Section()
            
            <<< PasswordRow() { row in
                row.title = "Contraseña anterior"
                row.placeholder = ""
                row.add(rule: RuleRequired())
                row.add(rule: RuleMinLength(minLength: 6, msg: "Mínimo 6 letras."))
                row.validationOptions = .validatesOnChange
                row.tag = "oldPass"
                
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            +++ Section()
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
   
    @objc func savePassword(_ sender: Any) {
        guard let new : String = self.form.rowBy(tag: "newPass")?.value, !new.isEmpty else {
            return
        }
        guard let old : String = self.form.rowBy(tag: "oldPass")?.value, !old.isEmpty else {
            return
        }
        store.dispatch(AuthSvc(.changePass(pass: new, oldPass: old)))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
extension PasswordChangeViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = AuthState
    
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            subcription in
            subcription.select { state in state.authState }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: AuthState) {
        self.view.hideToastActivity()
        switch state.state {
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            self.view.makeToast("Contraseña actualizada", duration: 2.0, position: .center)
            break
        case .failed:
            self.view.makeToast("Sucedio un error", duration: 3.0, position: .center)
            break
        default:
            break
        }
    }
}
