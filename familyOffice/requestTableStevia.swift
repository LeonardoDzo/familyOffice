//
//  requestTableStevia.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift
import Stevia

class RequestTableview: UIViewX {
    let tableView = UITableView()
    var type = 0
    var notificationToken: NotificationToken? = nil
    var rowActions: [UITableViewRowAction]!
    var assistants = [AssistantEntity]()
    convenience init() {
        self.init(frame:CGRect.zero)
        // This is only needed for live reload as injectionForXcode
        // doesn't swizzle init methods.
        // Get injectionForXcode here : http://johnholdsworth.com/injection.html
        
        render()
    }
    func render() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RequestAssistantCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
        sv(
            tableView
        )
        
        layout(
            0,
            |tableView|,
            0
        )
        self.tableView.tableFooterView = UIView()
        refreshData()
        tableView.reloadData()
    }
    
    func refreshData() -> Void {
        let backgroundnoevents = UIImageView()
        
        if assistants.count == 0 {
            
            backgroundnoevents.image = #imageLiteral(resourceName: "background_no_users")
            self.tableView.backgroundView = backgroundnoevents
            backgroundnoevents.contentMode = .scaleAspectFit
        }else{
            self.tableView.backgroundView = nil
        }
        self.tableView.reloadData()
        
    }
    deinit {
        notificationToken?.invalidate()
    }
}

extension RequestTableview: UITableViewDataSource, UITableViewDelegate {
    
    
    func numberOfRows(inSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assistants != nil ? assistants.count : 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = RequestAssistantCell()
        let assistant = assistants[indexPath.row]
        cell.assistant = assistant
        cell.render()
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}
