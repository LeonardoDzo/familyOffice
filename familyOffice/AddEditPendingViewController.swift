//
//  AddEditPendingViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 17/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import UIKit
import Eureka
import Toast_Swift

class AddEditPendingViewController: FormViewController, PendingBindable {
    var pending : PendingEntity! = PendingEntity()
    
    fileprivate func searchKey(_ key: String, _ value: Any?) {
        
            switch key {
            case "title":
                self.pending.title = value as! String
                break
            case "details":
                self.pending.details = value as! String
                break
            case "priority":
                self.pending.priority = value as? PENDING_PRIORITY ?? .Normal
                break
            case "done":
                self.pending.done = value as! Bool
                break
            default:
                break
            }
        
    }
    
    fileprivate func formSave() {
        try! rManager.realm.write {
            let valuesDictionary = form.values()
            valuesDictionary.forEach({ (key, value) in
                searchKey(key, value)
            })
        }
    }
    
    fileprivate func setupForm() -> Void {
         form +++ Section("")
            <<< TextRow() { row in
                row.title = "Titúlo"
                row.placeholder = "Título"
                row.tag = "title"
                row.value = pending.title
                row.add(rule: RuleRequired())
                }
            
            <<< TextAreaRow(){ row in
                row.title = "Descripción"
                row.placeholder = "Descripción"
                row.value = pending.details
                row.tag = "details"
            }
            <<< PushRow<PENDING_PRIORITY>() { row in
                row.title = "Prioridad"
                row.options = [.Low,.Normal,.High]
                row.value = self.pending.priority
                row.tag = "priority"
                row.selectorTitle = ""
                
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                }.onChange({ (row) in
                    if row.isValid {
                        row.updateCell()
                    }
                }).onPresent({ (form, to) in
                    to.navigationController?.setNavigationBarHidden(false, animated: true)
                    to.dismissOnSelection = true
                    to.dismissOnChange = false
                })
            <<< CheckRow() { row in
                row.tag = "done"
                row.title = "Finalizada"
                row.value = pending.done
                row.hidden = Condition(booleanLiteral: pending.id.isEmpty)
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupForm()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if pending.id.isEmpty {
            let addBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
            self.tabBarController?.navigationItem.rightBarButtonItem = addBtn
            self.tabBarController?.navigationItem.title = "Nueva Petición"
        }else{
            let editBtn = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.save))
            if let top = UIApplication.topViewController() {
                top.navigationItem.rightBarButtonItem = editBtn
                top.navigationItem.title = "Editar Petición"
            }
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    @objc func save() -> Void {
        let errors = form.validate()
        
        if errors.count == 0  {
            formSave()
            if pending.id.isEmpty {
                pending.boss = (getUser()?.id)!
                pending.id = UUID().uuidString
                if let assistant = getUser()?.assistants.first {
                    pending.assistantId = assistant.key
                    pending.created_at = Date().toMillis()
                    pending.updated_at = Date().toMillis()
                    store.dispatch(PendingSvc(.insert(pending: pending)))
                    pending = PendingEntity()
                    form.removeAll()
                    setupForm()
                }
            }else{
                try! rManager.realm.write {
                    pending.updated_at = Date().toMillis()
                }
                store.dispatch(PendingSvc(.update(pending: pending)))
                self.back3()
            }
        } else {
            let t = ToastStyle()
            self.view.makeToast("\(errors.description)", duration: 5.0, point: self.view.center, title: "Errores", image: nil, style: t, completion: nil)
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
