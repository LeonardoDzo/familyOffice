//
//  SafeBoxViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import SmileLock

class SafeBoxViewController: UIViewController {

    @IBOutlet weak var passwordStackView: UIStackView!
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create PasswordContainerView
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        
        //customize password UI
        passwordContainerView.tintColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        passwordContainerView.highlightedColor = #colorLiteral(red: 0.3137395978, green: 0.1694342792, blue: 0.5204931498, alpha: 1)
        self.navigationItem.title = "Caja Fuerte"
        self.setupBack()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="successSegue" {
            if let nvController = segue.destination as? UINavigationController {
                if let vcController = nvController.childViewControllers.first as? IndexViewController {
                    vcController.flag = true
                }
            }
        }
    }
}

extension SafeBoxViewController: PasswordInputCompleteProtocol {
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        }else{
            passwordContainerView.clearInput()
        }
    }

    
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        if validation(input) {
            validationSuccess()
        } else {
            validationFail()
        }
    }
    
}

private extension SafeBoxViewController {
    func validation(_ input: String) -> Bool {
        return input == "123456"
    }
    
    func validationSuccess() {
        print("*️⃣ success!")
        passwordContainerView.clearInput()
        self.performSegue(withIdentifier: "successSegue", sender: nil)
    }
    
    func validationFail() {
        print("*️⃣ failure!")
        passwordContainerView.wrongPassword()
    }
}
