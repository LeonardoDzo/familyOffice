//
//  FamilyViewController.swift
//  familyOffice
//
//  Created by Miguel Reina y Leonardo Durazo on 13/01/17.
//  Copyright © 2017 Miguel Reina y Leonardo Durazo. All rights reserved.


import UIKit
import FirebaseAuth
import ReSwift
class FamilyViewController: UIViewController, UIGestureRecognizerDelegate, FamilyBindable  {
    var family: Family!
    
    @IBOutlet weak var Image: CustomUIImageView!
    @IBOutlet weak var membersTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lpgr = UILongPressGestureRecognizer(target: self, action:#selector(handleLongPress(gestureReconizer:)))
        membersTable.addGestureRecognizer(lpgr )
        membersTable.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        let addButton : UIBarButtonItem = UIBarButtonItem(title: "Editar", style: UIBarButtonItemStyle.plain, target: self, action:#selector(addMemberScreen(sender:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.3137395978, green: 0.1694342792, blue: 0.5204931498, alpha: 1)]
        
        Image.formatView()
        membersTable.formatView()
    }
    
    
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Long press
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        let point: CGPoint = gestureReconizer.location(in: self.membersTable)
        let indexPath = self.membersTable?.indexPathForRow(at: point)
        
        if (indexPath != nil && (indexPath?.row)! < family.members.count) {
            switch gestureReconizer.state {
            case .began:
                
                let uid = family.members[(indexPath?.row)!]
                if let user = service.USER_SVC.getUser(byId: uid) {
                    if(user.id == Auth.auth().currentUser?.uid){
                        break
                    }
                    // create the alert
                    let alert = UIAlertController(title: user.name, message: "¿Qué deseas hacer?", preferredStyle: UIAlertControllerStyle.alert)
                    // add the actions (buttons)
                    alert.addAction(UIAlertAction(title: "Ver Perfil", style: UIAlertActionStyle.default, handler: {action in
                        self.performSegue(withIdentifier: "ProfileSegue", sender: user)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel, handler: nil))
                    if(family?.admin == Auth.auth().currentUser?.uid){
                        alert.addAction(UIAlertAction(title: "Remover de la familia", style: UIAlertActionStyle.destructive, handler:  { action in
                            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                               //Delete USER
                            }
                        }))
                    }
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
                break
            case .ended:
                print("termine")
                break
            default:
                break
            }
        }
    }
    @IBAction func handleExitFamily(_ sender: UIButton) {
        //Exit family
    }
 
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="editSegue"{
            let vc = segue.destination as! RegisterFamilyViewController
            if sender is Family {
                vc.bind(fam: sender as! Family)
            }
        }else if segue.identifier == "ProfileSegue" {
            let viewController = segue.destination as! ProfileUserViewController
            if sender is User {
                viewController.bind(userModel: sender as! User)
            }
        }
    }
    
}
extension FamilyViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return family.members.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FamilyMemberTableViewCell
        let uid = family.members[indexPath.row]
        if let member = service.USER_SVC.getUser(byId: uid) {
            cell.bind(userModel: member)
            cell.adminlabel.isHidden = family.admin == member.familyActive ?
                true : false
        }else{
            let user = User()
            cell.bind(userModel: user)
        }
        
        return cell
    }
}
extension FamilyViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = family?.name
        store.subscribe(self) {
            state in
            state
        }
        let ref = "families/\(family.id!)"
        service.FAMILY_SVC.valueSingleton(ref: ref)
    }
    
    func addMemberScreen(sender: UIBarButtonItem) -> Void {
        self.performSegue(withIdentifier: "editSegue", sender: family)
    }
    func newState(state: AppState) {
        family = state.FamilyState.families.family(fid: family.id)
        self.bind()
        self.membersTable.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        service.FAMILY_SVC.removeHandles()
    }
}
