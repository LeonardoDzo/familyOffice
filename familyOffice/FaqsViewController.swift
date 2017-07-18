//
//  FaqsViewController.swift
//  familyOffice
//
//  Created by miguel reina on 16/07/17.
//  Copyright © 2017 Miguel Reina. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class FaqsTableViewController: UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //configuration()
    }
    
    func setupNavBar(){
        /*let addButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.handleEdit))
        addButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        
        self.navigationItem.rightBarButtonItems = [ addButton]
        
        self.navigationItem.leftBarButtonItem = backButton*/
    }
    
    func back() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
