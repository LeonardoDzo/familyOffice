//
//  taskTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 16/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import Stevia
import RealmSwift

class TaskTableview: UIViewX {
    let tableView = UITableView()
    var type = 0
    var notificationToken: NotificationToken? = nil
    var rowActions: [UITableViewRowAction]!
    var pendings : Results<PendingEntity>!
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
        tableView.register(PendingCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
        sv(
            tableView
        )
        
        layout(
            0,
            |tableView|,
            0
        )
        rowActions = [
            UITableViewRowAction(style: .normal, title: "Editar", handler: {_, i in self.edit(i)}),
            UITableViewRowAction(style: .destructive, title: "Eliminar", handler: {_, i in self.remove(i)})
        ]
        self.tableView.tableFooterView = UIView()
        refreshData(0)
    }
    
    func refreshData(_ type: Int) -> Void {
        let backgroundnoevents = UIImageView()
        if type > 0 {
            let flag = type == 1 ? true : false
            pendings = rManager.realm.objects(PendingEntity.self).filter("done = %@", flag).sorted(byKeyPath: "created_at")
        }else{
            pendings = rManager.realm.objects(PendingEntity.self).sorted(byKeyPath: "priority", ascending: false).sorted(byKeyPath: "created_at")
        }
        if pendings.count == 0 {
           
            backgroundnoevents.image = #imageLiteral(resourceName: "background_no_pendings")
            self.tableView.backgroundView = backgroundnoevents
            backgroundnoevents.contentMode = .scaleAspectFit
        }else{
            self.tableView.backgroundView = nil
        }
        notificationToken?.invalidate()
        notificationToken = pendings.observe { [weak self] (changes: RealmCollectionChange) in
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
    func edit(_ indexPath: IndexPath) {
        if let top = UIApplication.topViewController() {
            let pending = pendings[indexPath.row]
            top.pushToView(view: .addEditPending, sender: pending)
        }
    }
    
    func remove(_ indexPath: IndexPath) {
        if let top = UIApplication.topViewController() {
            let alert = UIAlertController(title: "Eliminar", message: "¿Estás seguro que deseas eliminar este pendiente", preferredStyle: .alert)
            let pending = pendings[indexPath.row]
            alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive, handler: { (action) in
                store.dispatch(PendingSvc(.delete(ref: ref_pending(pending))))
            }))
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            top.present(alert, animated: true, completion: nil)
        }
       
        
        
    }
    deinit {
        notificationToken?.invalidate()
    }
}

extension TaskTableview: UITableViewDataSource, UITableViewDelegate {
   
    
    func numberOfRows(inSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendings != nil ? pendings.count : 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = PendingCell()
        let pending = pendings[indexPath.row]
        cell.bind(sender: pending)
        cell.render()
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return tableView.isEditing ? rowActions : [rowActions[1]]
    }
}
