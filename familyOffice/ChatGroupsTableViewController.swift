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
    
    var hasFamilyGroups: Bool {
        return self.restorationIdentifier! == "GroupsChat" ? true : false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBack()
    
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
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if !hasFamilyGroups { return nil }
//        if section == 0 {
//            return "Mas recientes"
//        }
//        var famId = user.familyActive
//        if section > 1 {
//            let fams: [RealmString] = user.families.filter({ $0.value != famId })
//            famId = fams[section - 2].value
//        }
//        return rManager.realm.objects(FamilyEntity.self).first(where: { $0.id == famId })?.name
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatGroupCell
        let group = groups[indexPath.row]
//        if hasFamilyGroups && indexPath.section != 0 {
//            var fam = user.familyActive
//            if indexPath.section > 1 {
//                let fams: [RealmString] = user.families.filter({ $0.value != fam })
//                fam = fams[indexPath.section - 2].value
//            }
//            group = groups.filter({ $0.familyId == fam })[indexPath.row]
//        }
        cell.bind(sender: group)
        guard let msgId = group.lastMessage else {
            return cell
        }
        if lastMessages[msgId] == nil {
            lastMessages[msgId] = .loading
            store.dispatch(getMessageAction(messageId: msgId, uuid: msgId))
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = groups[indexPath.row]
//        if hasFamilyGroups {
//            var fam = user.familyActive
//            if indexPath.section != 0 {
//                let fams: [RealmString] = user.families.filter({ $0.value != fam })
//                fam = fams[indexPath.section - 1].value
//            }
//            group = groups.filter({ $0.familyId == fam })[indexPath.row]
//        }
        self.pushToView(view: .chat, sender: group)
    }
    
    
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        selectedGroupIndex = indexPath.row
//        return indexPath
//    }
    
    func queryGroups() {
        groups = rManager.realm.objects(GroupEntity.self)
            .sorted(by: self.groupSorter)
            .filter({ group in
                if !hasFamilyGroups {
                    if group.isGroup { return false }
                    if group.lastMessage == nil { return false }
                } else if !group.isGroup { return false }
                return group.members.contains(where: { $0.id == user.id })
            })
//        tableView.reloadData()
//        tableView.tableFooterView = UIView()
    }
    
    func groupSorter(g1: GroupEntity, g2: GroupEntity) -> Bool {
        return groupOrder(group: g1) > groupOrder(group: g2)
    }
    
    func groupOrder(group: GroupEntity) -> Date {
        guard let messageId = group.lastMessage else {
            return group.createdAt
        }
        if let message = rManager.realm.objects(MessageEntity.self).first(where: { $0.id == messageId }) {
            return message.timestamp
        }
        if let messageResult = lastMessages[messageId] {
            switch messageResult {
            case .Finished(let message):
                return message.timestamp
            default: break
            }
        }
        return group.createdAt
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.subscribe(self) { store in
            store.select({ $0.requestState })
        }
        getGroupsReqId = UUID().uuidString
        store.dispatch(getAllGroupsAction(uuid: getGroupsReqId!))
        tableView.reloadData()
        if self.restorationIdentifier == "GroupsChat" {
            self.tabBarController?.title = "Grupos"
        } else {
            self.tabBarController?.title = "Chats"
        }
        
        if hasFamilyGroups {
            let editButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onAdd))
            self.tabBarController?.navigationItem.rightBarButtonItem = editButtonItem
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
        
        if hasFamilyGroups {
            self.tabBarController?.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func newState(state: RequestState) {
        guard let uuid = getGroupsReqId else { return }
        var reload = false
        switch state.requests[uuid] {
        case .finished?:
            reload = true
            store.dispatch(RequestAction.Processed(uuid: uuid))
            break
        default: break
        }
        
        lastMessages.forEach { (key, _) in
            switch state.requests[key] {
            case .finished?:
                let msg = rManager.realm.objects(MessageEntity.self).filter("id = '\(key)'").first!
                lastMessages[key] = .Finished(msg)
                store.dispatch(RequestAction.Processed(uuid: key))
                reload = true
            default: break
            }
        }
        if reload {
            queryGroups()
            tableView.reloadData()
        }
    }
}
