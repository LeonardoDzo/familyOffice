//
//  SafeboxPasswordViewController.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazar on 12/20/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import SmileLock
import Firebase
import ReSwift

class SafeboxPasswordViewController: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var stack: UIStackView!
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigits = 6
    var inputs: [String] = ["","",""]
    var index: Int = 0
    let user = getUser()
    var userEntity: UserEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userEntity = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: Auth.auth().currentUser?.uid)

        
        passwordContainerView = PasswordContainerView.create(in: stack, digit: kPasswordDigits)
        passwordContainerView.delegate = self
        passwordContainerView.touchAuthenticationEnabled = false
        
        passwordContainerView.tintColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        passwordContainerView.highlightedColor = #colorLiteral(red: 0.3137395978, green: 0.1694342792, blue: 0.5204931498, alpha: 1)
        
        setupBack()
        self.title = "Cambiar contraseña"
        titleLbl.text = "Contraseña actual"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SafeboxPasswordViewController: PasswordInputCompleteProtocol {
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            print("listooooo")
        }else{
            passwordContainerView.clearInput()
        }
    }
    
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        switch self.index {
        case 0:
            if validation(input) {
                self.index+=1
                titleLbl.text = "Nueva contraseña"
            } else {
                passwordContainerView.wrongPassword()
            }
            break
        case 1:
            self.inputs[self.index] = input
            self.index+=1
            break
        case 2:
            if validateNewPwd(input: input) {
                self.inputs[index] = input
//                self.user?.safeboxPwd = input
                try! rManager.realm.write {
                    self.user?.safeboxPwd = input
                }
                store.dispatch(UserS(.update(user: self.userEntity!, img: nil)))
                self.dismiss(animated: true, completion: nil)
            }else{
                passwordContainerView.wrongPassword()
                alertMessage(title: "Contraseñas no coinciden", msg: "")
                titleLbl.text = "Contraseña actual"
                self.index = 0
                self.inputs = ["","",""]
            }
            break
        default:
            break
        }
        print(self.inputs)
        passwordContainerView.clearInput()
    }
    
    func validateNewPwd(input: String) -> Bool{
        return input == self.inputs[self.index - 1]
    }
    
    func validation(_ input: String) -> Bool {
//        return input == "140320"
        return input == getUser()?.safeboxPwd
    }
}
