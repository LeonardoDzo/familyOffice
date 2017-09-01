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
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.selectRow(at: IndexPath(row: shareEvent.event.repeatmodel.frequency.hashValue, section: 0), animated: true, scrollPosition: .none)
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
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 6 {
            shareEvent.event.repeatmodel = repeatEvent()
            self.performSegue(withIdentifier: "customSegue", sender: nil)
            return
        }
        var frequency: Frequency!
        
        if indexPath.row == 3 {
            frequency = Frequency(rawValue: indexPath.row)
            
            shareEvent.event.repeatmodel.interval = 2
        }else if indexPath.row > 3 {
            frequency = Frequency(rawValue: indexPath.row-1)
        }
        shareEvent.event.repeatmodel.frequency = frequency
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "customSegue" {
            let vc = segue.destination as! CustomRepeatTableViewController
            vc.shareEvent = shareEvent
        }
    }
    
    
    
}
