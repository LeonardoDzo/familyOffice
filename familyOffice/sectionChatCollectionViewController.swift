//
//  ChatTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ChatTableViewController: BaseCell, UITableViewDelegate, UITableViewDataSource {
    var myconversations : [chatModel] = []
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    override func setupViews() {
        super.setupViews()
        myconversations = testFile().testChatConversations()
        addSubview(tableView)
        addContraintWithFormat(format: "H:|[v0]|", views: tableView)
        addContraintWithFormat(format: "V:|[v0]|", views: tableView)
        tableView.register(UINib(nibName: "chatCellTableViewCell", bundle: nil), forCellReuseIdentifier: "cellId")
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! chatCellTableViewCell
        let chat = myconversations[indexPath.row]
        cell.userImage.loadImage(urlString: chat.photoUrl)
        cell.nameLabel.text = chat.name
        cell.lastMessage.text = chat.lastMessage
        cell.time.text = chat.date
        
        // Configure the cell..
        return cell
    }
    
}

