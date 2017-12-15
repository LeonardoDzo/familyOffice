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
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var heightLayoutView: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var group: GroupEntity!
    var messages: Results<MessageEntity>!
    var users: Results<UserEntity>!
    var user = getUser()!
    var getMessagesUuid: String?
    var createMessageUuid: String?
    var reqs = [String: Result<Int>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        textField.delegate = self
        messages = rManager.realm.objects(MessageEntity.self)
            .filter("groupId = '\(group.id)'")
            .sorted(byKeyPath: "timestamp", ascending: true)
        var ids = [String]()
        group.members.forEach { (rstr) in
            ids.append("'\(rstr.value)'")
        }
        users = rManager.realm.objects(UserEntity.self)
            .filter("id IN {\(ids.joined(separator: ", "))}")
        title = group.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSend(_ sender: Any) {
        guard let text = textField.text, !text.isEmpty else { return }
        view.endEditing(true)
        let message = MessageEntity(value: [
            "groupId": group.id,
            "remittent": user.id,
            "text": text
        ])
        textField.text = ""
        createMessageUuid = UUID().uuidString
        store.dispatch(createMessageAction(entity: message, uuid: createMessageUuid!))
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(sender:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(sender:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        bottomConstraint.constant = keyboardSize - bottomLayoutGuide.length
        
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
        cell.bind(message: message, user: user, mine: self.user.id == user.id)
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
        registerKeyboardNotifications()
        store.subscribe(self)
        getMessagesUuid = UUID().uuidString
        store.dispatch(getAllMessagesAction(groupId: group.id, uuid: getMessagesUuid!))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let index = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: index, at: .bottom, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: AppState) {
        if let uuid = getMessagesUuid {
            switch state.requestState.requests[uuid] {
            case .finished?:
                if tableView.numberOfRows(inSection: 0) < messages.count {
                    let index = IndexPath(row: messages.count - 1, section: 0)
                    tableView.reloadData()
                    tableView.scrollToRow(at: index, at: .bottom, animated: false)
                }
                break
            default:
                break
            }
        }
        if let uuid = createMessageUuid {
            switch state.requestState.requests[uuid] {
            case .finished?:
//                tableView.reloadData() //.reloadSections(IndexSet(integer: 0), with: .automatic)
//                let indexPath = IndexPath(row: messages.count - 1, section: 0)
//                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                break
            default:
                break
            }
        }
        switch state.UserState.user {
        case .Finished(let action as UserAction):
            switch action {
            case .getbyId(let userId):
                reqs[userId] = .finished
                tableView.reloadData()
            default: break
            }
        default: break
        }
    }
    
}

extension ChatGroupViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let val = heightLayoutView.constant - textView.frame.size.height
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        heightLayoutView.constant = CGFloat(textView.frame.height + val)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n")
        {
            onSend(textView)
            return false
        }
        else
        {
            return true
        }
    }
}
