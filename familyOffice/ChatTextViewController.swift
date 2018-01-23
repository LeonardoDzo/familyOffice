//
//  ChatTextViewController.swift
//  familyOffice
//
//  Created by Nan Montaño on 12/ene/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import SlackTextViewController
import ReSwift
import RealmSwift

class ChatTextViewController: SLKTextViewController {
    var group: GroupEntity!
    var messages: Results<MessageEntity>!
    var getAllMessagesUuid: String?
    var createMessageUuid: String?
    let user = getUser()!
    var days: [Date] = []
    
    let myTitleView = FamilyTitleView.instanceFromNib()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.register(ChatTextMessageCell.self, forCellReuseIdentifier: "cell")
        if group != nil {
            messages = rManager.realm.objects(MessageEntity.self)
                .filter("groupId == '\(group.id)'")
                .sorted(byKeyPath: "timestamp", ascending: false)
            on("INJECTION_BUNDLE_NOTIFICATION") {
                // solo funciona por slk:
                // "If you access this property and its value is currently nil, the view controller automatically calls the loadView()
                // method and returns the resulting view."
                self.view = nil
            }
            setTitle()
            setDays()
            tableView?.separatorStyle = .none
            let isFamilyGroup = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: group.id) != nil
            if group.isGroup && !isFamilyGroup {
                let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.edit))
                self.navigationItem.rightBarButtonItem = button
            }
            self.isKeyboardPanningEnabled = true
        }
        
//        self.tableView?.allowsSelection = false
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
            }else if let user = rManager.realm.objects(AssistantEntity.self).first {
                myTitleView.titleLbl.text = user.name
                if !user.photoURL.isEmpty {
                    myTitleView.photo.loadImage(urlString: user.photoURL)
                } else {
                    myTitleView.photo.image = #imageLiteral(resourceName: "user-default")
                }
                myTitleView.titleLbl.textColor = UIColor.white
                self.tabBarController?.navigationItem.title = nil
                self.tabBarController?.navigationItem.rightBarButtonItem = nil
                self.tabBarController?.navigationItem.titleView = myTitleView
            }
        } else {
            myTitleView.titleLbl.text = group.title
            if !group.coverPhoto.isEmpty {
                myTitleView.photo.loadImage(urlString: group.coverPhoto)
            }
        }
        myTitleView.titleLbl.textColor = UIColor.white
        self.navigationItem.titleView = myTitleView
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
    
    @objc func edit() {
        let ctrl = NewChatGroupForm()
        ctrl.group = self.group
        show(ctrl, sender: self)
    }
    
    func messagesInSection(section: Int) -> Results<MessageEntity> {
        let today = days[section]
        var pred = NSPredicate(format: "timestamp > %@", today as CVarArg)
        if section > 0 {
            let tomorrow = days[section-1]
            pred = NSPredicate(format: "timestamp > %@ AND timestamp <= %@", today as CVarArg, tomorrow as CVarArg)
        }
        return messages.filter(pred)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesInSection(section: section).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ChatTextMessageCell(style: .default, reuseIdentifier: nil)
        let message = messagesInSection(section: indexPath.section)[indexPath.row]
        cell.transform = tableView.transform
        cell.bind(message: message)
        return cell
    }

//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let message = messagesInSection(section: indexPath.section)[indexPath.row]
//        return ChatTextMessageCell.calcHeight(message: message, width: tableView.frame.width)
//    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
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
        titleView.transform = tableView.transform
        return titleView
        
        //return ChatSectionHeaderView(tableFrame: tableView.frame, text: days[section].string(with: DateFormatter.dayMonthAndYear))
    }
    
    
    
    override func didPressRightButton(_ sender: Any?) {
        guard var text = textView.text else { return }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return; }
        createMessageUuid = UUID().uuidString
        let message = MessageEntity(value: [
            "id": createMessageUuid!,
            "groupId": group.id,
            "remittent": user.id,
            "text": text
        ])
        store.dispatch(createMessageAction(entity: message, uuid: message.id))
        super.didPressRightButton(sender)
    }
}

extension ChatTextViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = RequestState
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { state in
            state.select({ $0.requestState })
        }
        setTitle()
        getAllMessagesUuid = UUID().uuidString
        store.dispatch(getAllMessagesAction(groupId: group.id, uuid: getAllMessagesUuid!))
        store.dispatch(seenGroupAction(group: group, member: user.id, uuid: UUID().uuidString))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    func newState(state: RequestState) {
        if let uuid = getAllMessagesUuid {
            switch state.requests[uuid] {
            case .finished?:
                store.dispatch(RequestAction.Processed(uuid: uuid))
                setDays()
                tableView?.reloadData()
                tableView?.slk_scrollToTop(animated: true)
            default: break;
            }
        }
        if let uuid = createMessageUuid {
            switch state.requests[uuid] {
            case .finished?:
                store.dispatch(RequestAction.Processed(uuid: uuid))
                setDays()
                tableView?.reloadData()
                tableView?.slk_scrollToTop(animated: true)
            default: break;
            }
        }
    }
}
