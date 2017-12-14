//
//  ChatGroupsTableViewController.swift
//  familyOffice
//
//  Created by Nan Montaño on 12/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import RealmSwift

class ChatGroupsTableViewController: UITableViewController {
    
    var getGroupsReqId: String?
    let user = getUser()!
    var groups: Results<GroupEntity>!
    var selectedGroupIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBack()
        groups = rManager.realm.objects(GroupEntity.self)
            .filter("familyId = '\(user.familyActive)'")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let group = groups[indexPath.row]
        // Configure the cell...
        cell.textLabel?.text = group.title
        cell.detailTextLabel?.text = group.lastMessage ?? ""
        cell.imageView?.loadImage(urlString: group.coverPhoto)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedGroupIndex = indexPath.row
        return indexPath
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let ctrl = segue.destination as? ChatGroupViewController {
            ctrl.group = groups[selectedGroupIndex!]
        }
    }

}

extension ChatGroupsTableViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = RequestState
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { store in
            store.select({ $0.requestState })
        }
        getGroupsReqId = UUID().uuidString
        store.dispatch(getAllGroupsAction(familyId: user.familyActive, uuid: getGroupsReqId!))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    func newState(state: RequestState) {
        guard let uuid = getGroupsReqId else { return }
        switch state.requests[uuid] {
        case .loading?:
            break
        case .finished?:
            tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            break
        case .Failed(_)?:
            break
        default: break
        }
    }
}
