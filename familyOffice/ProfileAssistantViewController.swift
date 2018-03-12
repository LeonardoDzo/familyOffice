
//
//  ProfileAssistantViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 18/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import UIKit
import Charts
class ProfileAssistantViewController: UIViewController {
    var v = ProfileAssistantStevia()
   
    override func loadView() { view = v }
    override func viewDidLoad() {
        
        super.viewDidLoad()

        on("INJECTION_BUNDLE_NOTIFICATION") {
            self.v = ProfileAssistantStevia()
            self.view = self.v
            
        }
        
        v.topview.callBtn.btn.addTarget(self, action: #selector(self.call(_:)), for: .touchUpInside)
      
    }
    @objc func call(_ sender: UIButtonX){
        if let url = URL(string: "tel://\(sender.tag)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "Mi Asistente"
        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }

}
