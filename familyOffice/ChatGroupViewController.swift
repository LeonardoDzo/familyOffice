//
//  ChatGroupViewController.swift
//  familyOffice
//
//  Created by Nan Montaño on 12/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import RealmSwift

class ChatGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var group: GroupEntity!
    var messages: Results<MessageEntity>!
    var users: Results<UserEntity>!
    var user = getUser()!
    var getMessagesUuid: String?
    var createMessageUuid: String?
    var reqs = [String: Result<Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        messages = rManager.realm.objects(MessageEntity.self)
            .filter("groupId = '\(group.id)'")
        var ids = [String]()
        group.members.forEach { (rstr) in
            ids.append("'\(rstr.value)'")
        }
        users = rManager.realm.objects(UserEntity.self)
            .filter("id IN {\(ids.joined(separator: ", "))}")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSend(_ sender: UIButton) {
        guard let text = textField.text else { return }
        let message = MessageEntity(value: [
            "groupId": group.id,
            "remittent": user.id,
            "text": text
        ])
        textField.text = ""
        createMessageUuid = UUID().uuidString
        store.dispatch(createMessageAction(entity: message, uuid: createMessageUuid!))
    }
    
    
    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(messages)
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChatMessageBaseCell
        let message = messages[indexPath.row]
        guard let user = users.filter("id = '\(message.remittent)'").first else {
            if reqs[message.remittent] == nil {
                store.dispatch(UserS(.getbyId(uid: message.remittent)))
                reqs[message.remittent] = Result.loading
            }
            return cell
        }
        cell.bind(message: message, user: user, mine: message.remittent == user.id)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatMessageBaseCell else {
            return tableView.rowHeight
        }
        let width = tableView.frame.width
        let message = messages[indexPath.row]
        return cell.calcHeight(text: message.text, width: width)
    }

}

extension ChatGroupViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
        getMessagesUuid = UUID().uuidString
        store.dispatch(getAllMessagesAction(groupId: group.id, uuid: getMessagesUuid!))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: AppState) {
        if let uuid = getMessagesUuid {
            switchReq(state: state.requestState, uuid: uuid)
        }
        if let uuid = createMessageUuid {
            switchReq(state: state.requestState, uuid: uuid)
        }
        switch state.UserState.user {
        case .Finished(let action as UserAction):
            switch action {
            case .getbyId(let userId):
                reqs[userId] = .finished
                tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            default: break
            }
        default: break
        }
    }
    
    func switchReq(state: RequestState, uuid: String) {
        switch state.requests[uuid] {
        case .finished?:
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            break
        default:
            break
        }
    }
    
}
