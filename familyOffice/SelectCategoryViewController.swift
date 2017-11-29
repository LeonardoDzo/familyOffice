//
//  SelectCategoryViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 15/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import RealmSwift
import Firebase

class SelectCategoryViewController: UIViewController {
    var user: UserEntitie!
    var imageSelect : UIImage!
    var families : Results<FamilyEntitie>!
    var create = false
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var image: CustomUIImageView!
    @IBOutlet weak var familiesCollection: UICollectionView!
    @IBOutlet weak var familiasView: UIView!
    @IBOutlet weak var categoriasView: UIView!
    @IBOutlet weak var empresarialView: UIView!
    @IBOutlet weak var socialView: UIView!
    var localeChangeObserver :[NSObjectProtocol] = []
    override func viewDidLoad() {
        super.viewDidLoad()
       
        user = rManager.realm.object(ofType: UserEntitie.self, forPrimaryKey: Auth.auth().currentUser?.uid)
        style_1()
        let logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(self.logout))
        navigationItem.rightBarButtonItems = [logOutButton]
        headerView.formatView()
        familiasView.formatView()
        categoriasView.formatView()
        empresarialView.formatView()
        socialView.formatView()
   
     
    }
    
    @IBAction func handlePressSocial(_ sender: UIButton) {
        if families.count > 0{
            self.gotoView(view: .homeSocial)
        }
    }
    
    func dismissPopover(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
       
        self.familiesCollection.reloadData()
        
        store.subscribe(self) {
            state in
            state
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    func loadImage() -> Void {
        guard user != nil else {
            return
        }
        if !(user?.photoURL.isEmpty)! {
            image.loadImage(urlString: (user?.photoURL)!)
        }else{
            image.image = #imageLiteral(resourceName: "profile_default")
        }
        self.name.text = user?.name
        self.image.profileUser()
        self.familiesCollection.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        if defaults.value(forKey: "notification") != nil {
            defaults.removeObject(forKey: "notification")
        }
        
    }
    
    @IBAction func handleBussiness(_ sender: UIButton) {
        
        
    }
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    @objc func logout(){
        let action = AuthSvc()
        action.action = .logout
        store.dispatch(action)
        service.UTILITY_SERVICE.gotoView(view: "StartView", context: self)
    }
    
    
}
extension SelectCategoryViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    func newState(state: AppState) {
        loadImage()
        switch state.FamilyState.status {
        case .finished:
            families = rManager.realm.objects(FamilyEntitie.self)
            self.familiesCollection.reloadData()
            break
        case .Finished(let s as FamilyAction):
            if case let .insert(f) = s {
                self.pushToView(view: .profileFamily, sender: f)
            }
            break
        case .none:
            self.user.families.forEach({ (key) in
                store.dispatch(FamilyS(.getbyId(fid: key.value)))
            })
            break
        default:
            break
        }
    }
    
}
