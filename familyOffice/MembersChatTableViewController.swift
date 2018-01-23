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
    
    let user = getUser()!
    var group : GroupEntity! = nil
    
    fileprivate func loadFamily() {
        var membersIds = Set<String>()
        membersIds.insert(user.id)
        user.families.forEach({ famId in
            if let family = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: famId.value) {
                family.members.forEach({ (rs) in
                    if !membersIds.contains(rs.value) {
                        store.dispatch(UserS(.getbyId(uid: rs.value, assistant: false)))
                        membersIds.insert(rs.value)
                    }
                })
            }
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
        return user.families.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let famId = user.families[section].value
        let fam = rManager.realm.objects(FamilyEntity.self).first(where: { $0.id == famId })
        return (fam?.members.count ?? 1) - 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let famId = user.families[section].value
        let fam = rManager.realm.objects(FamilyEntity.self).first(where: { $0.id == famId })
        return fam?.name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemberTableViewCell
        
        cell.titleLbl.text = "Cargando ..."
        let famId = user.families[indexPath.section].value
        guard let fam = rManager.realm.objects(FamilyEntity.self).first(where: { $0.id == famId }) else {
            return cell
        }
        let uid = fam.members.filter("value != '\(user.id)'")[indexPath.row].value
        if let user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: uid) {
            cell.bind(sender: user)
        }

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let famId = user.families[indexPath.section].value
        guard let fam = rManager.realm.objects(FamilyEntity.self).first(where: { $0.id == famId }) else {
            return
        }
        let uid = fam.members.filter("value != '\(user.id)'")[indexPath.row].value
        group = rManager.realm.objects(GroupEntity.self).first { group in
            if !group.isGroup {
                var flag = false
                flag = group.members.contains(where: {$0.id == user.id}) && group.members.contains(where: {$0.id == uid})
                return flag
            }
            return false
        }
        if group == nil {
            group = GroupEntity()
     
            let myId = user.id
            group?.id = "\(uid < myId ? uid : myId)-\(uid < myId ? myId : uid)"
            group?.members.append(TimestampEntity(value: [uid, Date()]))
            group?.members.append(TimestampEntity(value: [myId, Date()]))
            group?.familyId = famId
            group?.isGroup = false
            store.dispatch(createGroupAction(group: group, uuid: group.id))
        }else{
            let ctrl = ChatTextViewController()
            ctrl.group = group
            self.navigationController?.pushViewController(ctrl, animated: true)
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
                let ctrl = ChatTextViewController()
                ctrl.group = group
                self.navigationController?.pushViewController(ctrl, animated: true)
                break
            default: return
            }
        }
        self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        
    }
}

