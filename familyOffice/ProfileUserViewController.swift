//
//  ProfileUserViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ProfileUserViewController: UIViewController, UserEModelBindable{
 
    var userModel: UserEntity!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var photo: UIImageViewX!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var birthdaylbl: UILabel!
    @IBOutlet weak var bloodtypeLbl: UILabel!
    @IBOutlet weak var nssLbl: UILabel!
    @IBOutlet weak var rfcLbl: UILabel!
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
}


