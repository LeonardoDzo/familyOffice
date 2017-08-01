//
//  addViewController.swift
//  familyOffice
//
//  Created by miguel reina on 25/05/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

//
//  HealthOmniViewController.swift
//  familyOffice
//
//  Created by Miguel reina on 04/abr/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {
    
    @IBOutlet weak var bCard: UIView!
    //@IBOutlet weak var backCard: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameField: textFieldStyleController!
    @IBOutlet weak var descriptionField: UITextView!
    var healthType : Int = -1
    var healthIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bCard.layer.borderWidth = 1
        self.bCard.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.bCard.layer.cornerRadius = 5
        let saveButton = UIBarButtonItem(title: "Guardar", style: .plain, target: self, action: #selector(save(sender:)))
        self.navigationItem.rightBarButtonItem = saveButton
        descriptionField.layer.borderWidth = 1
        descriptionField.layer.borderColor = UIColor.gray.cgColor
        nameField.layer.borderWidth = 1
        nameField.layer.borderColor = UIColor.gray.cgColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = healthIndex {
            let med = Constants.Services.USER_SERVICE.users[0].health.elements[index]
            nameField.text = med.name
            descriptionField.text = med.description
        }
        if self.healthType == Health.Element.typeOperation {
            nameLabel.text = "Tipo de operación"
        }else{
            nameLabel.text = "Nombre"
        }
        switch healthType {
        case Health.Element.typeMed:
            descriptionLabel.text = "Instrucciones"
        case Health.Element.typeDisease:
            descriptionLabel.text = "Síntomas, tratamiento"
        case Health.Element.typeDoctor:
            descriptionLabel.text = "Horario, teléfono, dirección"
        case Health.Element.typeOperation:
            descriptionLabel.text = "Fecha, tratamiento"
        default: descriptionLabel.text = "Descripción"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func save(sender: UIBarButtonItem){
        let name : String! = nameField.text
        if name == nil || name.isEmpty {
            Constants.Services.ANIMATIONS.shakeTextField(txt: nameField)
            return
        }
        
        let descriptionT : String! = descriptionField.text
        if descriptionT == nil || descriptionT.isEmpty {
            Constants.Services.ANIMATIONS.shakeTextField(txt: descriptionField)
            return
        }
        
        let element = Health.Element(name: name, type: healthType, description: descriptionT)
        var user = Constants.Services.USER_SERVICE.users[0]
        if let index = healthIndex {
            user.health.elements[index] = element
        } else {
            user.health.elements.append(element)
        }
        Constants.Services.USER_SERVICE.updateUser(user: user)
        navigationController!.popViewController(animated: true)
        
    }
    
}
