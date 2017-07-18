//
//  GoalDataofSectionTableViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 12/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class GoalDataofSectionTableViewCell: UITableViewCell {
    var data = [Goal]()
    
    weak var segueDelegate : Segue!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        setTableViewDataSourceDelegate()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func  setTableViewDataSourceDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = self.tag
        tableView.reloadData()
        
    }
    func chageHeight() -> Void {
        tableviewHeight.constant = CGFloat(data.count * 44)
    }

}
extension GoalDataofSectionTableViewCell: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GoalDataForCategoryTableViewCell
        let goal = data[indexPath.row]
        cell.bind(goal:goal)
        if  goal.follow.count == 0 {
            
            cell.doneSwitch.isHidden = false
            if goal.type == 0 {
                 cell.accessoryType = .none
                 cell.doneSwitch.isOn = goal.done
            }else{
                 let uid = store.state.UserState.user?.id
                cell.doneSwitch.isOn = goal.members[uid!]! > 0 ? true : false
            }
           
            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let goal = data[indexPath.row]
        if goal.type  == 1 {
             segueDelegate.selected("infoSegue", sender: goal)
        }else{
            if goal.follow.count > 0 {
                 segueDelegate.selected("detailSegue", sender: goal)
            }
        }
       
    }
    
    
}
