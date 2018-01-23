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
    var assistants : Results<AssistantEntity>!
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
        
        assistants = rManager.realm.objects(AssistantEntity.self)
        
        if assistants.count == 0 {
            
            backgroundnoevents.image = #imageLiteral(resourceName: "background_no_pendings")
            self.tableView.backgroundView = backgroundnoevents
            backgroundnoevents.contentMode = .scaleAspectFit
        }else{
            self.tableView.backgroundView = nil
        }
        notificationToken?.invalidate()
        notificationToken = assistants.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
        
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
