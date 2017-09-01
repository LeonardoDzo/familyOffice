//
//  NotificationsTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 26/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
class NotificationsTableViewController: UITableViewController {

    var notifications = [NotificationModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! recordTableViewCell
        let model = store.state.notifications[indexPath.row]
        cell.bind(model)
        return cell
    }

}
extension NotificationsTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            state in
            state
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: AppState) {
        notifications = state.notifications
        tableView.reloadData()
        if notifications.count == 0 {
        }
    }
}
