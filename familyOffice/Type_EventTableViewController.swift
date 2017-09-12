//
//  Type_EventTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 02/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit


class Type_EventTableViewController: UITableViewController {

    weak var shareEvent: ShareEvent!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        let val = shareEvent.event.type.hashValue
        tableView.selectRow(at: IndexPath(row: val, section: 0), animated: true, scrollPosition: .none)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shareEvent.event.type = eventType(rawValue: indexPath.row)
    }

}
