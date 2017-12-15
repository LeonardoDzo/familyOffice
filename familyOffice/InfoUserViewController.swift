//
//  InfoUserViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 14/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class InfoUserViewController: UITableViewController, UserEModelBindable {
    var userModel: UserEntity!
    
    @IBOutlet weak var bloodtypeLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var birthdaylbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var rfcLbl: UILabel!
    @IBOutlet weak var nssLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bind()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
