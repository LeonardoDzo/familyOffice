//
//  InsurancesViewController.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazat on 12/18/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift

class InsurancesViewController: UIViewController {
    var insurances: [Insurance] = []
    var filter: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(filter)
        switch filter {
        case "cars":
            self.title = "Carros"
            break
        case "homes":
            self.title = "Hogar"
            break
        case "medical":
            self.title = "Médicos"
            break
        case "life":
            self.title = "Vida"
            break
        default: break
        }
        // Do any additional setup after loading the view.
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
