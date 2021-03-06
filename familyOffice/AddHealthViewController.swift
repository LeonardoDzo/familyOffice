//
//  HealthOmniViewController.swift
//  familyOffice
//
//  Created by Miguel reina on 04/abr/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class AddHealthViewController: UIViewController {
    
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
        //self.backCard.layer.borderWidth = 1
        //self.backCard.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        //self.backCard.layer.cornerRadius = 5
        let saveButton = UIBarButtonItem(title: "Guardar", style: .plain, target: self, action: #selector(save(sender:)))
        self.navigationItem.rightBarButtonItem = saveButton
        
        if healthIndex != nil {
          
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
    
    override func viewWillAppear(_ animated: Bool) {
        
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
    
    @objc func save(sender: UIBarButtonItem){
        
    }
    
}
