
//
//  ProfileAssistantViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 18/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import UIKit

class ProfileAssistantViewController: UIViewController {
    var v = ProfileAssistantStevia()
    
    override func loadView() { view = v }
    override func viewDidLoad() {
        
        super.viewDidLoad()

        on("INJECTION_BUNDLE_NOTIFICATION") {
            self.v = ProfileAssistantStevia()
            self.view = self.v
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
