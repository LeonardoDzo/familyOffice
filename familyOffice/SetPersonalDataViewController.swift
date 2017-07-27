//
//  SetPersonalDataViewController.swift
//  familyOffice
//
//  Created by Miguel Reina on 30/01/17.
//  Copyright © 2017 Miguel Reina. All rights reserved.
//

import UIKit
import ReSwift
class SetPersonalDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, StoreSubscriber {
 
    var date : String!
    var phKeys = [("Nombre","name"), ("Teléfono","phone"), ("Dirección","address"), ("Fecha de Cumpleaños","birthday"),("",""), ("RFC","rfc"), ("CURP","curp"), ("NSS","nss"), ("Tipo de sangre","bloodType")]
    var pickerVisible = false
    var user: User!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainView: UIView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -40)
        tableView.layoutMargins = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        let homeButton : UIBarButtonItem = UIBarButtonItem(title: "Atras", style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(sender:)))
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.plain, target: self, action:#selector(save(sender:)))
        self.navigationItem.backBarButtonItem = homeButton
        self.navigationItem.rightBarButtonItem = doneButton
        tableView.tableFooterView = UIView()
        self.mainView.formatView()
        //loadInfo()
    }
    override func viewWillAppear(_ animated: Bool) {
        user = store.state.UserState.user
        
        store.subscribe(self){
            state in
            state.UserState
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        store.state.UserState.status = .none
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func back(sender: UIBarButtonItem) -> Void {
        _ =  navigationController?.popViewController(animated: true)
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return phKeys.count
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            pickerVisible = !pickerVisible
        }else{
            pickerVisible = false
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        if indexPath.row == 4 {
            
            if pickerVisible == false {
               
                return 0.0
            }
            
            return 165.0
        }
        return 44.0
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        print(sender.date)
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 4){
            let cell = tableView.dequeueReusableCell(withIdentifier: "datepickerCell", for: indexPath) as! DatePickerTableViewCell
            if !pickerVisible {
               // cell.datepicker.date = Date(string: user.birthday, formatter: .InternationalFormat)!
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PersonalDataTableViewCell
        if(indexPath.row == 3){
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            cell.myTextField.isEnabled = false
        }
        
        let obj = phKeys[indexPath.row]
        cell.configure(text: user?.toDictionary().object(forKey: obj.1) as! String!, placeholder: obj.0)
        return cell
    }
    
    //Private methods
    func setDate() -> Void {
        self.tableView.reloadData()
    }
    func save(sender: UINavigationBar) -> Void {
        var index = 0
        var userdictionary : [String: Any] = {
            return (user.toDictionary() as! [String : Any])
        }()
        while index < phKeys.count {
            let indexPath = NSIndexPath(row: index, section: 0)
            if(index != 4){
                let cell: PersonalDataTableViewCell? = self.tableView.cellForRow(at: indexPath as IndexPath) as? PersonalDataTableViewCell
                let value = cell?.myTextField.text
                let key = phKeys[index].1
                if key == "name" && value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)=="" {
                        service.ALERT_SERVICE.alertMessage(context: self, title: "Campo Vacío", msg: "El campo Nombre no puede quedar vacío")
                        service.ANIMATIONS.shakeTextField(txt: (cell?.myTextField)!)
                        return
                    
                }
                if key == "phone" && value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)=="" {
                        service.ALERT_SERVICE.alertMessage(context: self, title: "Campo Vacío", msg: "El campo Teléfono no puede quedar vacío")
                        service.ANIMATIONS.shakeTextField(txt: (cell?.myTextField)!)
                        return
                }
                
                userdictionary[key] = value
                
            }
            index += 1
        }
        user.fromDictionary(snapshotValue: userdictionary as NSDictionary)
        //Update
        store.dispatch(UpdateUserAction(user: user))
        _ =  navigationController?.popViewController(animated: true)
        //UTILITY_SERVICE.gotoView(view: "ConfiguracionScene", context: self)
    }
    
    func newState(state: UserState) {
        self.view.hideToastActivity()
        switch state.status {
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            self.view.makeToast("Datos Actualizados", duration: 2.0, position: .bottom)
            self.navigationController?.popViewController(animated: true)
            break
        case .failed:
            self.view.makeToast("Sucedio un error", duration: 2.0, position: .bottom)
            break
        default:
            break
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
