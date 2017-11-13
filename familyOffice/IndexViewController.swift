//
//  IndexViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class IndexViewController: UIViewController {
    var flag = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let barButton = UIBarButtonItem(title: "Atras", style: .plain, target: self, action: #selector(self.handleBack))
        self.navigationItem.leftBarButtonItem = barButton
        // Do any additional setup after loading the view.
        style_1()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFlag), name: notCenter.BACKGROUND_NOTIFICATION, object: nil)
        
        verify()
    }
    @objc func updateFlag() {
        flag  = false
        verify()
    }
    
    func verify() -> Void {
        if !flag {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        flag = false
        NotificationCenter.default.removeObserver(self, name: notCenter.BACKGROUND_NOTIFICATION, object: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func handleBack() {
        self.dismiss(animated: true, completion: nil)
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
