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
        cell.bind(sender: group)
//        guard let msgId = group.lastMessage else {
//            cell.bind(group: group)
//            return cell
//        }
//        let msgResult = lastMessages[msgId]
//        var msg: MessageEntity? = nil
//        switch msgResult {
//        case nil:
//            lastMessages[msgId] = .loading
//            store.dispatch(getMessageAction(messageId: msgId, uuid: msgId))
//            break
//        case .Finished(let m)?:
//            msg = m
//            break
//        default: break
//        }
//        // Configure the cell...
//        cell.bind(group: group, lastMessage: msg)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = self.groups[indexPath.row]
        self.pushToView(view: .chat, sender: group)
    }
    
    
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        selectedGroupIndex = indexPath.row
//        return indexPath
//    }
    
    func queryGroups() {
        let str: String = self.restorationIdentifier!
        let flag = str == "GroupsChat" ? true : false
        groups = rManager.realm.objects(GroupEntity.self)
            .filter("familyId = '\(user.familyActive)' AND isGroup == \(flag)")
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
        if !flag {
            groups = groups.filter { (group) -> Bool in
                if group.members.count == 2 {
                    var flag = false
                    flag = group.members.contains(where: {$0.value == getUser()?.id})
                    return flag
                }
                return false
            }
        }
        tableView.reloadData()
        tableView.tableFooterView = UIView()
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if let ctrl = segue.destination as? ChatGroupViewController {
//            ctrl.group = groups[selectedGroupIndex!]
//        }
//    }

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
