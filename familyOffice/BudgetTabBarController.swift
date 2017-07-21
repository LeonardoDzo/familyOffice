//
//  BudgetTabBarController.swift
//  familyOffice
//
//  Created by Nan Montaño on 17/jul/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class BudgetTabBarController: UITabBarController {
    
    let settingLauncher = SettingLauncher()
    var values = [BudgetConcept]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Presupuesto"
        // setup nav bar
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Home"), style: .plain, target: self, action: #selector(self.onBack))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_more_button"), style: .plain, target: self, action: #selector(self.onMore))
        
        let conceptNames = ["Comida", "Transporte", "Alojamiento", "Entretenimiento", "Hogar", "Otros"]
        let year2017 = Date(string: "01 01 2017", formatter: DateFormatter.dayMonthAndYear)!
        let almostAYear : UInt32 = 60*60*24*364
        for _ in 0..<100 {
            values.append(BudgetConcept(
                name: conceptNames[Int(arc4random_uniform(UInt32(conceptNames.count)))],
                amount: Double(arc4random_uniform(10000)) - 5000,
                date: Date(timeInterval: TimeInterval(arc4random_uniform(almostAYear)), since: year2017)
            ))
        }
        values.sort(by: {(a, b) in a.date < b.date})
		
        let lineChartCtrl = viewControllers?[0] as! LineChartViewController
        let radarChartCtrl = viewControllers?[1] as! RadarChartViewController
        let tableCtrl = viewControllers?[2] as! BudgetViewController
        print(lineChartCtrl, radarChartCtrl, tableCtrl)
        
        lineChartCtrl.setData(concepts: values, initialBudget: Double(arc4random_uniform(10000)))
        radarChartCtrl.setData(concepts: values)
        tableCtrl.values = values
        
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
    
    func onBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func onMore(){
        settingLauncher.showSetting()
    }

}
