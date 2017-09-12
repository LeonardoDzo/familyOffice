//
//  NewHealthElementTableViewController.swift
//  familyOffice
//
//  Created by Nan Montaño on 07/abr/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class NewHealthElementViewController: UITableViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    
    var healthType : Int = -1
    var healthIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return healthType == Health.Element.typeOperation ? "Tipo de operación" :"Nombre"
        }
        switch healthType {
        case Health.Element.typeMed:
            return "Instrucciones"
        case Health.Element.typeDisease:
            return "Síntomas, tratamiento"
        case Health.Element.typeDoctor:
            return "Horario, teléfono, dirección"
        case Health.Element.typeOperation:
            return "Fecha, tratamiento"
        default: return nil
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func save(sender: UIBarButtonItem){
                
    }

}
