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
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        if let str: String = self.restorationIdentifier {
            switch str {
            case "tabbarfirstAidKit":
                self.setStyle(.firstaidkit)
                break
            case "tabbarchat":
                self.setStyle(.chat)
                break
            case "TabBarControllerView":
                self.tabBar.items?.last?.title = "Perfil"
                self.tabBar.items?.last?.image = #imageLiteral(resourceName: "Setting")
                break
            default:
                
                break
            }

        }
        self.setupBack()
        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
    }

}
