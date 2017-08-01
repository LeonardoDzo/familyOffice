//
//  GoalDataForCategoryTableViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 12/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class GoalDataForCategoryTableViewCell: UITableViewCell, GoalBindable {
    var goal: Goal!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var endDateLbl: UILabel!
    @IBOutlet weak var doneSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
  
    @IBAction func handleChange(_ sender: UISwitch) {
        if goal.type == 0 {
            goal.done = sender.isOn
        }else{
            let uid = store.state.UserState.user?.id
            goal.members[uid!] = sender.isOn ? Date().toMillis() : -1
        }
        
        store.dispatch(UpdateGoalAction(goal: self.goal))
    }
    

}
