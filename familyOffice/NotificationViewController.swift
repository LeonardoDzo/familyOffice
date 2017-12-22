//
//  NotificationViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 20/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import RealmSwift

class NotificationViewController: UIViewController {
    var notificationToken: NotificationToken? = nil
    @IBOutlet weak var tableView: UITableView!
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
            self.tableView.backgroundView = nil
        }else{
            let imageView = UIImageViewX()
            imageView.image = #imageLiteral(resourceName: "background_no_notifications")
            self.tableView.backgroundView = imageView
            imageView.contentMode = .scaleAspectFit
            imageView.filter = #colorLiteral(red: 0.9332545996, green: 0.9333854914, blue: 0.9332134128, alpha: 0.601654196)
        }
        notifications = rManager.realm.objects(NotificationModel.self).sorted(byKeyPath: "timestamp", ascending: false)
       
      
        
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
    
}

extension NotificationViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications != nil ? notifications.count : 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationCell
        let notification = notifications[indexPath.row]

        cell.bind(notification)
        return cell
    }
}

