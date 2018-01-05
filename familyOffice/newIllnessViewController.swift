//
//  newIllnessViewController.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/24/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import ReSwift
class NewIllnessViewController: UIViewController {
    
    @IBOutlet var illName: UITextField!
    @IBOutlet var illMedicine: UITextView!
    @IBOutlet var illDosage: UITextView!
    @IBOutlet var illMoreInfo: UITextView!
    
    
    var isEdit:Bool = false
    var illness:Illness! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        if isEdit{
            illName.text = illness.name
            illMedicine.text = illness.medicine
            illDosage.text = illness.dosage
            illMoreInfo.text = illness.moreInfo
        }
        
        self.illMedicine.layer.borderWidth = 1
        self.illMedicine.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.illMedicine.layer.cornerRadius = 5
        
        self.illDosage.layer.borderWidth = 1
        self.illDosage.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.illDosage.layer.cornerRadius = 5
        
        self.illMoreInfo.layer.borderWidth = 1
        self.illMoreInfo.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.illMoreInfo.layer.cornerRadius = 5
        
        let saveButton = UIBarButtonItem(title:!isEdit ? "Guardar" : "Editar", style: .plain, target: self, action: #selector(save(sender:)))
        self.navigationItem.rightBarButtonItem = saveButton
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func save(sender: UIBarButtonItem){
        let iName:String! = illName.text
        let iMedicine:String! = illMedicine.text
        let iDosage:String! = illDosage.text
        let iMoreInfo:String! = illMoreInfo.text
        
        if iName == nil || iName.isEmpty{
            service.ANIMATIONS.shakeTextField(txt: illName)
            self.view.makeToast("Agregue un nombre")
            return
        }
        if isEdit{
            self.illness.name = iName
            self.illness.medicine = iMedicine
            self.illness.dosage = iDosage
            self.illness.moreInfo = iMoreInfo
            print(self.illness)
            store.dispatch(UpdateIllnessAction(illness: self.illness))
        }else{
            self.illness = Illness(name: iName, medicine: iMedicine, dosage: iDosage, moreInfo: iMoreInfo, type: 0)
            store.dispatch(InsertIllnessAction(illness: self.illness))
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

extension NewIllnessViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = IllnessState
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        store.subscribe(self){
            subcription in
            subcription.select { state in state.IllnessState }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.state.IllnessState.status = .none
        store.unsubscribe(self)
    }
    
    func newState(state: IllnessState) {
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
