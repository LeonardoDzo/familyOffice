//
//  MainTabBarController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 26/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        if let value : Int = store.state.notifications.count as? Int, value > 0 {
            self.tabBarController?.tabBar.items?[3].badgeValue = String(value)
        }
        
    }

}
