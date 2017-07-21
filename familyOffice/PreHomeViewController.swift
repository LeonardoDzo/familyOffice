//
//  SelectCategoryViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 15/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
class SelectCategoryViewController: UIViewController {
    var user: User?
    var imageSelect : UIImage!
    var families = [Family]()
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
        let logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(self.logout))
        logOutButton.tintColor = #colorLiteral(red: 1, green: 0.1757333279, blue: 0.2568904757, alpha: 1)
        navigationItem.rightBarButtonItems = [logOutButton]
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.3137395978, green: 0.1694342792, blue: 0.5204931498, alpha: 1)]
        
        self.headerView.layer.borderWidth = 1
        self.headerView.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.familiasView.layer.borderWidth = 1
        self.familiasView.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.familiasView.layer.cornerRadius = 5
        self.categoriasView.layer.borderWidth = 1
        self.categoriasView.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.categoriasView.layer.cornerRadius = 5
        self.socialView.layer.borderWidth = 1
        self.socialView.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.socialView.layer.cornerRadius = 5
        self.empresarialView.layer.borderWidth = 1
        self.empresarialView.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.empresarialView.layer.cornerRadius = 5
    }
    @IBAction func handlePressSocial(_ sender: UIButton) {
        if families.count > 0{
            service.UTILITY_SERVICE.gotoView(view: "TabBarControllerView", context: self)
        }
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
        //self.image.layer.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
    }
    
    @IBAction func handleBussiness(_ sender: UIButton) {
        if service.FAMILY_SERVICE.families.count > 0 && service.FAMILY_SERVICE.families.contains(where: {$0.id == service.USER_SERVICE.users[0].familyActive}){
            service.UTILITY_SERVICE.gotoView(view: "HomeBussiness", context: self)
        }
        
    }
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "registerSegue" {
            let vc = segue.destination as! RegisterFamilyViewController
            let family = Family()
            vc.bind(fam: family)
        }
    }
    
    func logout(){
        service.AUTH_SERVICE.logOut()
        service.UTILITY_SERVICE.gotoView(view: "StartView", context: self)
    }
    
    
}
extension SelectCategoryViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    func newState(state: AppState) {
        user = state.UserState.user
        if user != nil {
            loadImage()
            verifyUser(status: state.UserState.status)
            verifyFamilies(state: state.FamilyState)
        }
    }
    func verifyFamilies(state: FamilyState) -> Void {
        if families.count != state.families.items.count {
            families = state.families.items
            addFamily(family: families.last!)
        }else{
            self.familiesCollection.reloadData()
        }
    }
    func verifyUser(status: Result<Any>){

        switch status {
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            self.view.hideToastActivity()
            break
        default:
            break
        }
    }
}
