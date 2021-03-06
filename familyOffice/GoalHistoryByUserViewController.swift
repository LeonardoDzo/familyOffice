//
//  GoalHistoryByUserViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 14/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Charts

class GoalHistoryByUserViewController: UIViewController, GoalBindable {
    var goal: Goal!
    var user: User!
    var follow: Goal!
    var path: String!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var starEndDate: UILabel!
    @IBOutlet weak var completeLbl: UILabel!
    @IBOutlet weak var restLbl: UILabel!
    @IBOutlet weak var incompLbl: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var dateForCompleate: UILabel!
    @IBOutlet weak var doneSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var firstView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstView.formatView()
        secondView.formatView()
        pieChart.formatView()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.bind(goal: goal)
        self.goal.list = goal.list
        if goal != nil {
            starEndDate.text = getDate(goal.startDate, with: .dayMonthAndYear2) + "-" + getDate(goal.endDate!, with: .dayMonthAndYear2)
        }
        self.navigationItem.title = user.name
        updatePieChartData()
        verifyFollow()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updatePieChartData()  {
        self.pieChart.clear()
        let sdata = values()
        // 3. chart setup
        let set = PieChartDataSet( values: [], label: "")
        var colors: [UIColor] = [#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1),#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)]
        
        for (i,value) in sdata.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = Double(value)
            if value > 0 {
                set.values.append(entry)
            }else{
                if i < colors.count {
                    colors.remove(at: i)
                }
                
                
            }
        }
        set.colors = colors
        let data = PieChartData(dataSet: set)
        
        //Set Formatter
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        data.setValueFormatter(formatter)
        
        pieChart.data = data
        pieChart.noDataText = "No existen objetivos"
        // user interaction
        pieChart.isUserInteractionEnabled = true
        //pieChart.legend = Legend(entries: [])
        incompLbl.text = sdata[1].description
        completeLbl.text = sdata[0].description
        restLbl.text = sdata[2].description
        pieChart.chartDescription?.text = ""
        pieChart.centerText = "Obj."
        pieChart.holeRadiusPercent = 0.5
        pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInCirc)
        pieChart.legend.enabled = false
        pieChart.transparentCircleColor = UIColor.clear
        
    }
    func getDate(_ timestampt: Int,with formatter: DateFormatter ) -> String {
        return Date(timeIntervalSince1970: TimeInterval(timestampt/1000)).string(with: formatter)
    }
    func values() -> [Int] {
        var count = 0
        var incomplete = 0
        var rest = 0
        let date = Date().toMillis()
        for item in goal.list {
            if item.members[user.id]! > 0 {
                count+=1
            }else{
                if date! >= item.startDate! {
                    incomplete+=1
                }else {
                    rest+=1
                }
            }
            
        }
        return [count, incomplete, rest]
    }
    
}

extension GoalHistoryByUserViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goal.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TimeLineCellTableViewCell
        let follow = goal.list[indexPath.row]
        cell.doneLbl.text = Date(timeIntervalSince1970: TimeInterval(follow.startDate/1000)).string(with: .ddMMMyyyy)
        if indexPath.row == goal.list.count {
            cell.lineLbl.isHidden = true
        }
        cell.dateLbl.text = Date(timeIntervalSince1970: TimeInterval(follow.startDate/1000)).string(with: .ddMMMyyyy)

        cell.doneLbl.text = follow.members[user.id!]! > 0 ? getDate(follow.members[user.id!]!, with: .dayMonthAndYear2) : "Incompleta"
        if follow.members[user.id!]! > 0  {
            cell.doneLbl.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            cell.doneLbl.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.doneLbl.layer.borderColor = UIColor.clear.cgColor
        }else{
            cell.doneLbl.backgroundColor = UIColor.clear
            cell.doneLbl.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            cell.doneLbl.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        }
        return cell
    }
    
    func verifyFollow() -> Void {
        
        let date = Date().toMillis()
        let follows = goal.list.sorted(by: {$0.startDate < $1.startDate})
        for item in follows {
            if date! <= item.startDate! {
                follow = item
                let string = "Fecha: "
                self.dateForCompleate.text = string +  Date(timeIntervalSince1970: TimeInterval(item.startDate/1000) ).string(with: .ddMMMyyyy)
                if user.id == userStore?.id {
                    self.doneSwitch.isOn = follow.members[(user?.id!)!]! > 0 ? true : false
                    self.dateForCompleate.isHidden = false
                    self.doneSwitch.isHidden = false
                }
                break
            }
        }
        
    }
    @IBAction func handleChange(_ sender: UISwitch) {
        var path = "goals/\(user.id!)/\(goal.id!)/follows"
        if service.GOAL_SERVICE.type != .Individual {
            if let fid = userStore?.familyActive {
                path = "goals/\(fid)/\(goal.id!)/follows"
            }
        }
        var xgoal: Goal!
       
        if follow != nil, let index = goal.list.index(where: {$0.startDate == follow.startDate}), let uid = userStore?.id
        {
            goal.list[index].members[uid] = sender.isOn ? Date().toMillis() : -1
            xgoal = goal.list[index]
            path += "/\(goal.startDate!)"

        }
        store.dispatch(gac.UpdateFollow(path, goal: xgoal))
        updatePieChartData()
        self.tableView.reloadData()
        
    }
}
