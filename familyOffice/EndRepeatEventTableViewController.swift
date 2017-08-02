//
//  EndRepeatEventTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 09/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class EndRepeatEventTableViewController: UITableViewController {
    var value = 0
    weak var shareEvent : ShareEvent!
    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        let quitButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.cancel))
        
        navigationItem.rightBarButtonItems = [addButton,quitButton]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        var indexpath : IndexPath!
        value = shareEvent.event.repeatmodel.end
        if value == 0  {
           indexpath = IndexPath(row: 0,section:0)
        }else{
            indexpath = IndexPath(row: 1,section:0)
        }
        datePicker.minimumDate = Date(timeIntervalSince1970: TimeInterval(shareEvent.event.endDate/1000))
        tableView.selectRow(at: indexpath, animated: true, scrollPosition: .none)
        tableView.cellForRow(at: indexpath)?.accessoryType = .checkmark
        
    }
    
    func dismissPopover() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func save() -> Void {
        shareEvent?.event.repeatmodel.end = value
        dismissPopover()
        
    }
    func cancel() -> Void {
        dismissPopover()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row != 2 {
           
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPath = indexPath
        if indexPath.row != 2 {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            if indexPath.row == 0 {
                value = 0
                indexPath.row = 1
            }else {
                value = datePicker.date.toMillis()
                indexPath.row = 0
            }
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 2 {
                if value == 0 {
                    return 0.0
                }else{
                    return 200.0
                }
            }
        }
        return 44.0
    }
    
    func activeAccesory(indexPath: IndexPath){
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    @IBAction func handleChangeDpicker(_ sender: UIDatePicker) {
        value = sender.date.toMillis()
    }
 
    
}
