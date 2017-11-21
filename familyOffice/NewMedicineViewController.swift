//
//  NewMedicineViewController.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/21/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import ReSwift

class NewMedicineViewController: UIViewController {
    
    var isEdit:Bool = false
    var medicine:Medicine! = nil

    @IBOutlet var medNameTextField: UITextField!
    @IBOutlet var medIndicTextField: UITextView!
    @IBOutlet var medDosageTextField: UITextView!
    @IBOutlet var medRestrTextField: UITextView!
    @IBOutlet var medMoreTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        if isEdit{
            medNameTextField.text = medicine.name
            medIndicTextField.text = medicine.indications
            medDosageTextField.text = medicine.dosage
            medRestrTextField.text = medicine.restrictions
            medMoreTextField.text = medicine.moreInfo
        }
        
        self.medIndicTextField.layer.borderWidth = 1
        self.medIndicTextField.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.medIndicTextField.layer.cornerRadius = 5
        
        self.medDosageTextField.layer.borderWidth = 1
        self.medDosageTextField.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.medDosageTextField.layer.cornerRadius = 5
        
        self.medRestrTextField.layer.borderWidth = 1
        self.medRestrTextField.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.medRestrTextField.layer.cornerRadius = 5
        
        self.medMoreTextField.layer.borderWidth = 1
        self.medMoreTextField.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.medMoreTextField.layer.cornerRadius = 5
        
        let saveButton = UIBarButtonItem(title:!isEdit ? "Guardar" : "Editar", style: .plain, target: self, action: #selector(save(sender:)))
        self.navigationItem.rightBarButtonItem = saveButton

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func save(sender: UIBarButtonItem){
        let medName:String! = medNameTextField.text
        let medIndications:String! = medIndicTextField.text
        let medDosage:String! = medDosageTextField.text
        let medRestrictions:String! = medRestrTextField.text
        let medMoreInfo:String! = medMoreTextField.text
        
        if medName == nil || medName.isEmpty{
            service.ANIMATIONS.shakeTextField(txt: medNameTextField)
            self.view.makeToast("Agregue un nombre")
            return
        }
        if isEdit{
            self.medicine.name = medName
            self.medicine.indications = medIndications
            self.medicine.dosage = medDosage
            self.medicine.restrictions = medRestrictions
            self.medicine.moreInfo = medMoreInfo
            store.dispatch(UpdateMedicineAction(medicine: self.medicine))
        }else{
            self.medicine = Medicine(name: medName, indications: medIndications, dosage: medDosage, restrictions: medRestrictions, moreInfo: medMoreInfo)
            store.dispatch(InsertMedicineAction(medicine: self.medicine))
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

}

extension NewMedicineViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = MedicineState
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        store.subscribe(self){
            subcription in
            subcription.select { state in state.MedicineState }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.state.MedicineState.status = .none
        store.unsubscribe(self)
    }
    
    func newState(state: MedicineState) {
        switch state.status {
        case .failed:
            self.view.makeToast("Ocurrió un error, intente nuevamente")
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            self.view.hideToastActivity()
            _ = self.navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
    }
}
