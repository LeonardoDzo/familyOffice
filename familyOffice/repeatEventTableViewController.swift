//
//  repeatEventTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 08/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit


class repeatEventTableViewController: UITableViewController {
    weak var shareEvent: ShareEvent!
    var select : Int! = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        let quitButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.cancel))
        
        navigationItem.rightBarButtonItems = [addButton,quitButton]
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.selectRow(at: IndexPath(row: desc_Int(shareEvent.event.repeatmodel.frequency), section: 0), animated: true, scrollPosition: .none)
        block()
    }
    
    func block() -> Void {
        for i in 1..<6 {
            var value = 1
            switch i {
            case 1:
                value = 1
                break
            case 2:
                value = 7
                break
            case 3:
                value = 14
                break
            case 4:
                value = 28
                break
            case 5:
                value = 365
                break
            default:
                break
            }
            let date1 = Date(timeIntervalSince1970: TimeInterval(shareEvent.event.date/1000)).addingTimeInterval(TimeInterval(60*60*24*value)).toMillis()
            
            if date1! <= shareEvent.event.endDate {
                let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0))
                cell?.selectionStyle = .none
                cell?.isUserInteractionEnabled = false
            }
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func dismissPopover() {
        _ = navigationController?.popViewController(animated: true)    }
    
    func save() -> Void {
        //shareEvent?.event.repeatmodel = select
        dismissPopover()
        
    }
    func cancel() -> Void {
        dismissPopover()
    }
    
    func desc_Int(_ frequency: String) -> Int {
        switch frequency {
        case "day":
            return 1
        case "week":
            return 2
        case "week":
            return 2
        case "month":
            return 4
        case "year":
            return 5
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let frequency = REPEAT_TYPE(rawValue: indexPath.row)
        shareEvent.event.repeatmodel.frequency = frequency?.description
        if frequency == REPEAT_TYPE.WEEKLY_2 {
            shareEvent.event.repeatmodel.each = 2
        }else{
            shareEvent.event.repeatmodel.each = 1
        }
    }
    
    
    
}
