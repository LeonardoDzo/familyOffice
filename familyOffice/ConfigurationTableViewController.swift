//
//  ConfigurationTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 27/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ConfigurationTableViewController: UITableViewController {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
       
        tableView.layoutMargins = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        tableView.tableFooterView = UIView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if(indexPath.row == 3){
             service.AUTH_SERVICE.logOut()
             Utility.Instance().gotoView(view: "StartView", context: self)
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
