 //
//  MembersChatTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 16/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
class MembersChatTableViewController: UITableViewController {
    var group : GroupEntity! = nil
    var family : FamilyEntity!
    var members = [String]()
    
    fileprivate func loadFamily() {
        family = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: getUser()?.familyActive)
        if family != nil {
            family.members.forEach({ (rs) in
                store.dispatch(UserS(.getbyId(uid: rs.value)))
            })
        }
        members = family.members.filter({$0.value != getUser()?.id}).map({ (rs) -> String in
            return rs.value
        })
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
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
        return members.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemberTableViewCell
        
        let uid = members[indexPath.row]
        cell.profileImage.hideToastActivity()
        if let user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: uid) {
            cell.bind(sender: user)
        }else{
            cell.titleLbl.text = "Cargando ..."
            cell.profileImage.makeToastActivity(.center)
        }

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uid = members[indexPath.row]
        group = rManager.realm.objects(GroupEntity.self).first { group in
            if !group.isGroup {
                var flag = false
                flag = group.members.contains(where: {$0.id == getUser()?.id}) && group.members.contains(where: {$0.id == uid})
                return flag
            }
            return false
        }
        if group == nil {
            group = GroupEntity()
     
            let myId = getUser()!.id
            group?.id = "\(uid < myId ? uid : myId)-\(uid < myId ? myId : uid)"
            group?.members.append(TimestampEntity(value: [uid, Date()]))
            group?.members.append(TimestampEntity(value: [myId, Date()]))
            group?.familyId = family.id
            group?.isGroup = false
            store.dispatch(createGroupAction(group: group, uuid: group.id))
        }else{
            self.pushToView(view: .chat, sender: group)
        }
    }

}

extension MembersChatTableViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = RequestState
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        group = nil
        loadFamily()
        store.subscribe(self) { store in
            store.select({ $0.requestState })
        }
        self.tabBarController?.title = "Miembros"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    func newState(state: RequestState) {
        if group != nil, !group.id.isEmpty {
            switch state.requests[group.id] {
            case .finished?:
                self.pushToView(view: .chat, sender: group)
                break
            default: return
            }
        }
        self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        
    }
}

