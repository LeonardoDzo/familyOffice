//
//  mainCalendarViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 01/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class mainCalendarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        self.setStyle(.calendar)
        self.setupBack()
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
         
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
