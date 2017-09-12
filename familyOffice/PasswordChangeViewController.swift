//
//  PasswordChangeViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
class PasswordChangeViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var repeatPass: UITextField!
    @IBOutlet weak var viewContainer: UIView!
    
    override func viewDidLoad() {
        let homeButton : UIBarButtonItem = UIBarButtonItem(title: "Atras", style: .plain, target: self, action: #selector(back(sender:)))
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Cambiar", style: UIBarButtonItemStyle.plain, target: self, action:#selector(changePassword(sender:)))
        
        self.navigationItem.backBarButtonItem = homeButton
        self.navigationItem.rightBarButtonItem = doneButton
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        /// Textfields cutomitazions
        let color = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        oldPassword.borderbottom(color: color, width: 1.0)
        newPassword.borderbottom(color: color, width: 1.0)
        repeatPass.borderbottom(color: color, width: 1.0)
        self.viewContainer.formatView()
        // Do any additional setup after loading the view.
    }
   
    @IBAction func savePassword(_ sender: Any) {
        changePassword(sender: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func back(sender: UIBarButtonItem) -> Void {
        _ =  navigationController?.popViewController(animated: true)
    }
    
    func changePassword(sender: UIBarButtonItem?) -> Void {
        
        guard let oldPass = oldPassword.text, !oldPass.isEmpty else {
            self.alertMessage(title: "Campo vacío", msg: "El campo Contraseña actual no puede estar vacío")
            oldPassword.shakeTextField()
            return
        }
        guard let newPass = newPassword.text, !newPass.isEmpty, newPass.characters.count >= 6 else {
            newPassword.shakeTextField()
            self.alertMessage(title: "Campo vacío", msg: "El campo Contraseña nueva no puede estar vacío o al menos debe contener 6 caracteres")
            return
        }
        guard let rptPass = repeatPass.text, !rptPass.isEmpty, rptPass.characters.count >= 6 else {
            repeatPass.shakeTextField()
            self.alertMessage( title: "Campo vacío", msg: "El campo Contraseña nueva no puede estar vacío o al menos debe contener 6 caracteres")
            return
        }
        
        if rptPass == newPass {
            //Action change pass
            store.dispatch(ChangePassUserAction(pass: newPass, oldPass: oldPass))
        }else{
            repeatPass.shakeTextField()
            newPassword.shakeTextField()
            self.alertMessage(title: "Error", msg: "Contraseñas no coinciden")
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
         service.UTILITY_SERVICE.moveTextField(textField: textField, moveDistance: -200, up: true, context: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
         service.UTILITY_SERVICE.moveTextField(textField: textField, moveDistance: -200, up: false, context: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
extension PasswordChangeViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = UserState
    
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            subcription in
            subcription.select { state in state.UserState }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.state.UserState.status = .none
        store.unsubscribe(self)
    }
    
    func newState(state: UserState) {
        self.view.hideToastActivity()
        switch state.status {
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            self.view.makeToast("Contraseña actualizada", duration: 2.0, position: .center)
            break
        case .failed:
            self.view.makeToast("Sucedio un error", duration: 2.0, position: .center)
            break
        default:
            break
        }
    }
}
