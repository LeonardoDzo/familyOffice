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
    var groups: [GroupEntity] = []
    var lastMessages = [String: Result<MessageEntity>]()
    var selectedGroupIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBack()
        
        let editButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onAdd))
        self.navigationItem.rightBarButtonItem = editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onAdd() {
        let ctrl = NewChatGroupForm()
        show(ctrl, sender: self)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatGroupCell
        let group = groups[indexPath.row]
        guard let msgId = group.lastMessage else {
            cell.bind(group: group)
            return cell
        }
        let msgResult = lastMessages[msgId]
        var msg: MessageEntity? = nil
        switch msgResult {
        case nil:
            lastMessages[msgId] = .loading
            store.dispatch(getMessageAction(messageId: msgId, uuid: msgId))
            break
        case .Finished(let m)?:
            msg = m
            break
        default: break
        }
        // Configure the cell...
        cell.bind(group: group, lastMessage: msg)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedGroupIndex = indexPath.row
        return indexPath
    }
    
    func queryGroups() {
        groups = rManager.realm.objects(GroupEntity.self)
            .filter("familyId = '\(user.familyActive)'")
            .sorted(by: { (g1, g2) -> Bool in
                var t1 = g1.createdAt, t2 = g2.createdAt
                if let id1 = g1.lastMessage, let r1 = lastMessages[id1] {
                    switch r1 {
                    case .Finished(let m1):
                        t1 = m1.timestamp
                    default: break
                    }
                }
                if let id2 = g2.lastMessage, let r2 = lastMessages[id2] {
                    switch r2 {
                    case .Finished(let m2):
                        t2 = m2.timestamp
                    default: break
                    }
                }
                return t1 > t2
            })
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
        var reload = false
        switch state.requests[uuid] {
        case .finished?:
            reload = true
            queryGroups()
            break
        default: break
        }
        
        lastMessages.forEach { (key, _) in
            switch state.requests[key] {
            case .finished?:
                let msg = rManager.realm.objects(MessageEntity.self).filter("id = '\(key)'").first!
                lastMessages[key] = .Finished(msg)
                queryGroups()
                reload = true
            default: break
            }
        }
        if reload {
            tableView.reloadData()
        }
    }
}
