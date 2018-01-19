//
//  MainAssistantViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 16/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import UIKit

class MainAssistantViewController: UIViewController {
    var v = MainAssistantViewStevia()
    
    override func loadView() { view = v }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        on("INJECTION_BUNDLE_NOTIFICATION") {
            self.v = MainAssistantViewStevia()
            self.view = self.v
        }

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.showEditing))
        
        self.tabBarController?.navigationItem.rightBarButtonItem = editButton
        self.tabBarController?.navigationItem.title = "Peticiones"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showEditing(sender: UIBarButtonItem)
    {
        if(v.table.tableView.isEditing)
        {
            v.table.tableView.setEditing(false, animated: true)
            self.tabBarController?.navigationItem.rightBarButtonItem?.title = "Editar"
        }
        else
        {
            v.table.tableView.setEditing(true, animated: true)
            self.tabBarController?.navigationItem.rightBarButtonItem?.title = "Listo"
        }
    }
    @objc
    func login() {
        print("login tapped")
    }

}
