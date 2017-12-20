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
    var days: [Date] = []
    var users: Results<UserEntity>!
    var user = getUser()!
    var getMessagesUuid: String?
    var createMessageUuid: String?
    var reqs = [String: Result<Int>]()
    let myTitleView = FamilyTitleView.instanceFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        textField.delegate = self
        tableView.contentMode = .bottom
        messages = rManager.realm.objects(MessageEntity.self)
            .filter("groupId = '\(group.id)'")
            .sorted(byKeyPath: "timestamp", ascending: true)
        var ids = [String]()
        group.members.forEach { (rstr) in
            ids.append("'\(rstr.id)'")
        }
        users = rManager.realm.objects(UserEntity.self)
        setTitle()
        setDays()
        tableView.scrollToBottom(animated: true)
        myTitleView.titleLbl.textColor = UIColor.white
        self.navigationItem.titleView = myTitleView
        
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.edit))
        self.navigationItem.rightBarButtonItem = button
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSend(_ sender: Any) {
        guard let text = textField.text, !text.isEmpty else { return }
        createMessageUuid = UUID().uuidString
        let message = MessageEntity(value: [
            "id": createMessageUuid!,
            "groupId": group.id,
            "remittent": user.id,
            "text": text
        ])
        textField.text = ""
        store.dispatch(createMessageAction(entity: message, uuid: message.id))
    }
    
    @objc func edit() {
        let ctrl = NewChatGroupForm()
        ctrl.group = self.group
        show(ctrl, sender: self)
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
            if self.messages.count > 0 {
                let contentHeight = self.tableView.contentSize.height
                let frameHeight = self.tableView.frame.height
                self.tableView.contentOffset.y = max(contentHeight - frameHeight, 0)
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    func setTitle() {
        myTitleView.photo.image = #imageLiteral(resourceName: "background_family")
        if !group.isGroup {
            let otherUser = group.members.first { self.user.id != $0.id }
            if let user = rManager.realm.objects(UserEntity.self).filter("id = '\(otherUser!.id)'").first {
                myTitleView.titleLbl.text = user.name
                if !user.photoURL.isEmpty {
                    myTitleView.photo.loadImage(urlString: user.photoURL)
                } else {
                    myTitleView.photo.image = #imageLiteral(resourceName: "user-default")
                }
            }
        } else {
            myTitleView.titleLbl.text = group.title
            if !group.coverPhoto.isEmpty {
                myTitleView.photo.loadImage(urlString: group.coverPhoto)
            }
        }
    }
    
    func setDays() {
        days = []
        messages.forEach { msg in
            let date = msg.timestamp.midnight()
            if !days.contains(where: { $0 == date }) {
                days.append(date)
            }
        }
    }
    
    func messagesInSection(section: Int) -> Results<MessageEntity> {
        let today = days[section]
        var pred = NSPredicate(format: "timestamp > %@", today as CVarArg)
        if section < days.count - 1 {
            let tomorrow = days[section+1]
            pred = NSPredicate(format: "timestamp > %@ AND timestamp <= %@", today as CVarArg, tomorrow as CVarArg)
        }
        return messages.filter(pred)
    }
    
    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
        let date = days[section]
        var datestring = date.string(with: DateFormatter.ddMMMyyyy).uppercased()
        if date.isToday() { datestring = "HOY" }
        else if date.isYesterday() { datestring = "AYER" }
        let titleView = UILabelX(text: datestring)
        titleView.backgroundColor = UIColor(hex: "#b8d5e2")
        titleView.textAlignment = .center
        titleView.textColor = UIColor.white
        titleView.font = UIFont.systemFont(ofSize: 12)
        return titleView
        
        //return ChatSectionHeaderView(tableFrame: tableView.frame, text: days[section].string(with: DateFormatter.dayMonthAndYear))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesInSection(section: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChatMessageBaseCell
        let message = messagesInSection(section: indexPath.section)[indexPath.row]
        guard users.filter("id = '\(message.remittent)'").count > 0 else {
            if reqs[message.remittent] == nil {
                store.dispatch(UserS(.getbyId(uid: message.remittent)))
                reqs[message.remittent] = Result.loading
            }
            return cell
        }
        cell.bind(message: message, group: group)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatMessageBaseCell else {
            return tableView.rowHeight
        }
        let width = tableView.frame.width
        let message = messages[indexPath.row]
        return cell.calcHeight(message: message, width: width)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return messages[indexPath.row].status == MessageStatus.Failed.rawValue ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let msg = messages[indexPath.row]
        store.dispatch(createMessageAction(entity: msg, uuid: msg.id))
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
        store.dispatch(seenGroupAction(group: group, member: user.id, uuid: UUID().uuidString))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if messages.count > 0 {
            tableView.scrollToBottom(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: AppState) {
        if let uuid = getMessagesUuid {
            switch state.requestState.requests[uuid] {
            case .finished?:
                let lastSection = tableView.numberOfSections - 1
                var rows = -1
                if lastSection >= 0 {
                    rows = tableView.numberOfRows(inSection: lastSection)
                }
                setDays()
                tableView.reloadData()
                if rows != tableView.numberOfRows(inSection: lastSection) {
                    tableView.scrollToBottom(animated: true)
                }
                store.dispatch(RequestAction.Processed(uuid: uuid))
                break
            default:
                break
            }
        }
        if let uuid = createMessageUuid {
            switch state.requestState.requests[uuid] {
            case .finished?:
                setDays()
                tableView.reloadData()
                tableView.scrollToBottom(animated: true)
                store.dispatch(RequestAction.Processed(uuid: uuid))
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
                setTitle()
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
