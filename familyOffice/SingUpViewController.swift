//
//  SingUpViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 03/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import ReSwift
class SingUpViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    
    typealias StoreSubscriberStateType = UserState
    
    @IBOutlet weak var nameTxtfield: UITextField!
    @IBOutlet weak var emailTxtfield: UITextField!
    @IBOutlet weak var phoneTxtfield: UITextField!
    @IBOutlet weak var passwordTxtfield: UITextField!
    @IBOutlet weak var confirmPassTxtfield: UITextField!
    
    
    override func viewDidLoad() {
        //AUTH_SERVICE.isAuth(view: self.self, name:"TabBarControllerView")
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        // Do any additional setup after loading the view.
        let backButton : UIBarButtonItem = UIBarButtonItem(title: "Atrás", style: UIBarButtonItemStyle.plain, target: self, action:#selector(handleBack))
        self.navigationItem.leftBarButtonItem = backButton
        self.confirmPassTxtfield.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Registrar"
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        STYLES.borderbottom(textField: self.nameTxtfield, color: UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1), width: 1.0)
        STYLES.borderbottom(textField: self.emailTxtfield, color: UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1), width: 1.0)
        STYLES.borderbottom(textField: self.phoneTxtfield, color: UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1), width: 1.0)
        STYLES.borderbottom(textField: self.passwordTxtfield, color: UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1), width: 1.0)
        STYLES.borderbottom(textField: self.confirmPassTxtfield, color: UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1), width: 1.0)
        store.subscribe(self) {
            state in
            state.UserState
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func handleSingUp(_ sender: UIButton) {
        var er: String?
        
        guard let name = nameTxtfield.text, !name.isEmpty else {
            er = "Nombre debe ser capturado"
            service.ANIMATIONS.shakeTextField(txt: nameTxtfield)
            return
        }
        
        guard let pass :String = passwordTxtfield.text, !pass.isEmpty,  pass == confirmPassTxtfield.text, (passwordTxtfield.text?.characters.count)! > 5 else{
            er = "La contraseña y confirmación de contraseña deben ser capturadas"
            service.ANIMATIONS.shakeTextField(txt: passwordTxtfield)
            service.ANIMATIONS.shakeTextField(txt: confirmPassTxtfield)
            service.ANIMATIONS.shakeTextField(txt: passwordTxtfield)
            return
        }
        
        guard let email = emailTxtfield.text, !email.isEmpty else {
            er = "Correo electrónico debe ser capturado"
            service.ANIMATIONS.shakeTextField(txt: emailTxtfield)
            return
        }
        
        guard let phone = phoneTxtfield.text, !phone.isEmpty else {
            er = "Celular debe ser capturado"
            service.ANIMATIONS.shakeTextField(txt: phoneTxtfield)
            return
        }
        
        guard pass == confirmPassTxtfield.text else {
            er = "Contraseñas no coinciden"
            service.ANIMATIONS.shakeTextField(txt: passwordTxtfield)
            service.ANIMATIONS.shakeTextField(txt: confirmPassTxtfield)
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: pass) { (user, error) in
            if(error == nil){
                let userModel = User(id: (user?.uid)!, name: name, phone: phone, photoURL: "", families: [:], familyActive: "", rfc: "", nss: "", curp: "", birth: "", address: "", bloodtype: "", health: [])
                store.dispatch(CreateUserAction(user: userModel))
                Constants.FirDatabase.REF_USERS.child(userModel.id).setValue(userModel)
            }
            else{
                let errCode : FIRAuthErrorCode = FIRAuthErrorCode(rawValue: error!._code)!
                switch errCode {
                case .errorCodeInvalidEmail:
                    er = "Correo electrónico incorrecto"
                case .errorCodeWrongPassword:
                    er = "Contraseña incorrecta"
                case .errorCodeWeakPassword:
                    er = "La contraseña debe de contener al menos 6 caracteres"
                default:
                    er = "Algo salio mal, intente más tarde"
                }
            }
            
        }
        
        if(er != nil ){
            let alert = UIAlertController(title: "Verifica tus datos", message: er, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func handleBack(_ sender: UIButton) {
        service.UTILITY_SERVICE.gotoView(view: "StartView", context: self)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func googlePlusTouchUpInside(sender: AnyObject){
        GIDSignIn.sharedInstance().signIn()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField: textField, moveDistance: -200, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField: textField, moveDistance: -200, up: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func moveTextField(textField: UITextField, moveDistance: Int, up: Bool){
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance: -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
}
extension SingUpViewController : StoreSubscriber {
    func newState(state: UserState) {
        self.view.hideToastActivity()
        switch state.status {
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            _ = self.navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
    }
}
