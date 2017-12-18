//
//  ProfileUserViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ProfileUserViewController: UIViewController, UserEModelBindable{
 
    var userModel: UserEntity! = getUser()
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var photo: UIImageViewX!
    @IBOutlet weak var confBtn: UIButton!
    
    @IBOutlet weak var infoView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
       self.bind()
        if !userModel.isUserLogged() {
            confBtn.isHidden = true
        }
        
        if  tabBarController?.restorationIdentifier != "TabBarControllerView" || (tabBarController?.tabBar.isHidden)! {
            self.setupButtonback()
        }
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    @IBAction func handleGoConfig(_ sender: Any) {
        self.gotoView(view: .confView, sender: self.userModel, navigation: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "infoSegue" {
            if let vc = segue.destination as? InfoUserViewController {
                vc.bind(userModel: self.userModel)
            }
        }
    }
}


