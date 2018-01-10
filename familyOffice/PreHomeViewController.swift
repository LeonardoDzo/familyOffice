//
//  PreHomeViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 04/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift

class PreHomeViewController: UIViewController, UserEModelBindable {
    internal var userModel: UserEntity!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageViewX!
    @IBOutlet weak var familycounterLbl: UILabel!
    @IBOutlet weak var confStack: UIStackView!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleConf(_:)))
        self.confStack.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func handleConf(_ sender: UIButtonX) {
        
        self.pushToView(view: .profileView, sender: getUser())
    }
    

    override func viewWillAppear(_ animated: Bool) {
        store.state.UserState.user = .none
        self.bind()
        store.subscribe(self) {
            state in
            state.select({ (s) in
                s.FamilyState
            })
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func toggleSelect(family: FamilyEntity){
        store.dispatch(UserS( .selectFamily(family: family)))
    }
    func promptForAnswer() {
        let alertController = UIAlertController(title: "Crear Familia", message: "Ingresa el nombre de la familia", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Crear", style: .default) { (_) in
            
            guard let text = alertController.textFields?[0].text, !text.isEmpty else {
                return
            }
            let family = FamilyEntity()
            family.name = text
            store.dispatch(FamilyS(.insert(family: family)))
            
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Nombre de la familia"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func handleAddFamily(_ sender: UIButtonX) {
        promptForAnswer()
    }
    @IBAction func logout(_ sender: Any) {
        store.dispatch(AuthSvc(.logout))
    }
    
}
extension PreHomeViewController : StoreSubscriber {
    
    typealias StoreSubscriberStateType = FamilyState
    
    func newState(state: FamilyState) {
        
        if case let .Finished(action) = store.state.UserState.user {
            if let a = action as? UserAction {
                if case .selectFamily(_) = a {
                   self.gotoView(view: .homeSocial, sender: getUser())
                }
            }
        }
        
        switch state.status {
        case .finished:
            self.tableView.reloadData()
            break
        case .Finished(let s as FamilyAction):
            if case let .insert(f) = s {
                self.pushToView(view: .profileFamily, sender: f)
            }
            break
        case .none:
            self.userModel.families.forEach({ (key) in
                store.dispatch(FamilyS(.getbyId(fid: key.value)))
            })
            break
        default:
            break
        }
        switch store.state.authState.state {
            case .loading: // hotfix, si luego explota, el neto del 9 de enero del 2018 dice hola
                self.dismiss(animated: true, completion: nil)
                break
            case .Finished(_ as AuthAction):
                if let top = UIApplication.topViewController() {
                    top.popToView(view: .start)
                }
                break
            default: break
            }
        if pendingNotification != nil {
            gotoNotification(pendingNotification)
        }
    }
    
}
extension PreHomeViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userModel.families.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! familyTableViewCell
        let fid = userModel.families[indexPath.row].value
        
        if let family = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: fid) {
            cell.bind(fam: family)
        }else{
            cell.titleLbl.text = "Cargando ..."
        }
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Familias"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let family = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: userModel.families[indexPath.row].value) {
             toggleSelect(family: family)
        }
    }
    
}
