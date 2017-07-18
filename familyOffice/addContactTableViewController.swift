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
class addContactTableViewController: UITableViewController, ContactBindible {
    var contact: Contact!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var jobTxt: UITextField!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var webpageTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    
    var isEdit = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //configuration()
        store.subscribe(self) {
            state in
            state.ContactState
        }
        
        self.bind(contact: contact)
        isEdit = !contact.name.isEmpty
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)

    }
    func save(sender: UIBarButtonItem) {
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
        guard let name = self.nameTxt.text, !name.isEmpty, name.characters.count >= 3 else {
            self.view.makeToast("Escriba un nombre válido", duration: 1.0, position: .top)
            return false
        }
        guard let phone = self.phoneTxt.text, !phone.isEmpty, phone.characters.count >= 10 else {
            self.view.makeToast("Escriba un teléfono válido", duration: 1.0, position: .top)
            return false
        }
        guard let job = self.jobTxt.text, !job.isEmpty else {
            self.view.makeToast("Escriba un oficion válido", duration: 1.0, position: .top)
            return false
        }
        
        return true
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
            break
        default:
            break
        }
    }
    
}
