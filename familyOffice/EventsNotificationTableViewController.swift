//
//  EventsNotificationTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import RealmSwift
class EventsNotificationTableViewController: UITableViewController {

    var notificationToken: NotificationToken? = nil
    var notifications : Results<NotificationModel>!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        if notificationarray.count > 0{
            rManager.saveObjects(objs: notificationarray)
        }
        tableView.tableFooterView = UIView()
        notifications = rManager.realm.objects(NotificationModel.self).filter("type = %@", Notification_Type.event.rawValue).sorted(byKeyPath: "timestamp", ascending: false)
        
        if notifications.count == 0 {
            let imageView = UIImageViewX()
            imageView.image = #imageLiteral(resourceName: "background_no_notifications")
            self.tableView.backgroundView = imageView
            imageView.contentMode = .scaleAspectFit
            imageView.filter = #colorLiteral(red: 0.9332545996, green: 0.9333854914, blue: 0.9332134128, alpha: 0.601654196)
        }else{
            self.tableView.backgroundView = UIView()
        }
        // Observe Results Notifications
        notificationToken = notifications.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                self?.tableView.backgroundView = UIView()
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
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications != nil ? notifications.count : 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationCell
        let notification = notifications[indexPath.row]
        print(notification)
        if !notification.seen {
            cell.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 0.08)
        }else{
            cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        cell.bind(notification)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        try! rManager.realm.write {
            notification.seen = true
            self.tableView.reloadRows(at: [indexPath], with: .fade)
            
        }
    }
}
