//
//  addContactTableViewController.swift
//  familyOffice
//
//  Created by miguel reina on 27/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Toast_Swift
import ContactsUI

class addContactTableViewController: UITableViewController, ContactBindible, CNContactPickerDelegate {
    var contact: Contact!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var jobTxt: UITextField!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var webpageTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet var importButton: UIButton!
    
    var isEdit = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //configuration()
        store.subscribe(self) {
            subcription in
            subcription.select { state in state.ContactState }
        }
        self.bind(contact: contact)
        isEdit = !contact.name.isEmpty
        if isEdit{
            importButton.setTitle("Importar datos", for: .normal)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)

    }
    @objc func save(sender: UIBarButtonItem) {
        if !validation() {
           return
        }
        contact.name = nameTxt.text
        contact.phone = phoneTxt.text
        contact.job = jobTxt.text
        contact.address = addressTxt.text
        contact.webpage = webpageTxt.text
        contact.email = emailTxt.text
        if isEdit {
            store.dispatch(UpdateContactAction(contact: contact))
        }else{
            store.dispatch(InsertContactAction(contact: contact))
        }
        
    }
    
    func validation() -> Bool {
        guard let name = self.nameTxt.text, !name.isEmpty, name.count >= 3 else {
            self.view.makeToast("Escriba un nombre válido", duration: 1.0, position: .top)
            return false
        }
        guard let phone = self.phoneTxt.text, !phone.isEmpty, phone.count >= 10 else {
            self.view.makeToast("Escriba un teléfono válido", duration: 1.0, position: .top)
            return false
        }
        guard let job = self.jobTxt.text, !job.isEmpty else {
            self.view.makeToast("Escriba un oficion válido", duration: 1.0, position: .top)
            return false
        }
        
        return true
    }
    
    @IBAction func importButtonPressed(_ sender: UIButton) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    // MARK:- Método de ContactPickerDelegate
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        var addressStr:String = ""
        
        if contact.postalAddresses.count > 0 {
            let address = contact.postalAddresses[0]
            let street = address.value.street
            let postalCode = address.value.postalCode
            let city = address.value.city
            let state = address.value.state
            addressStr = "\(street), \(postalCode), \(city), \(state)"
        }
        
        
        self.contact.name = "\(contact.givenName) \(contact.familyName)"
        self.contact.phone = contact.phoneNumbers[0].value.stringValue
        self.contact.address = addressStr
        self.contact.webpage = contact.urlAddresses.count > 0 ? contact.urlAddresses[0].value as String : ""
        self.contact.email = contact.emailAddresses.count > 0 ? contact.emailAddresses[0].value as String : ""
        
    }
    
}
extension addContactTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = ContactState
    
    func newState(state: ContactState) {
        switch state.status {
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            self.view.hideToastActivity()
            _ = self.navigationController?.popViewController(animated: true)
            store.state.ContactState.status = .none //hotfix
            break
        default:
            break
        }
    }
    
}
