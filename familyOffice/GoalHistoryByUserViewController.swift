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
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var starEndDate: UILabel!
    @IBOutlet weak var completeLbl: UILabel!
    @IBOutlet weak var restLbl: UILabel!
    @IBOutlet weak var incompLbl: UILabel!
    var follow : FollowGoal!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var dateForCompleate: UILabel!
    @IBOutlet weak var doneSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.bind(goal: goal)
        self.goal.follow = goal.follow.sorted(by: {$0.date < $1.date})
        if goal != nil {
            starEndDate.text = getDate(goal.startDate, with: .dayMonthAndYear2) + "-" + getDate(goal.endDate, with: .dayMonthAndYear2)
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
        for item in goal.follow {
            let comp = Date(string: item.date, formatter: .ShortInternationalFormat)?.toMillis()
            if item.members[user.id]! > 0 {
                count+=1
            }else{
                if date! >= comp! {
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
        return goal.follow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TimeLineCellTableViewCell
        let follow = goal.follow[indexPath.row]
        cell.doneLbl.text = Date(string: follow.date, formatter: .ShortInternationalFormat)?.string(with: .dayMonthAndYear2)
        if indexPath.row == goal.follow.count {
            cell.lineLbl.isHidden = true
        }
        cell.dateLbl.text = follow.date
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
        let follows = goal.follow.sorted(by: {$0.date < $1.date})
        for item in follows {
            let comp = Date(string: item.date, formatter: .ShortInternationalFormat)?.toMillis()
            if date! <= comp! {
                follow = item
                let string = "Fecha: "
                self.dateForCompleate.text = string + item.date
                if user.id == store.state.UserState.user?.id {
                    self.doneSwitch.isOn = follow.members[(user?.id!)!]! > 0 ? true : false
                    self.dateForCompleate.isHidden = false
                    self.doneSwitch.isHidden = false
                }
                break
            }
        }
        
    }
    @IBAction func handleChange(_ sender: UISwitch) {
        
        if follow != nil, let index = goal.follow.index(where: {$0.date == follow.date}), let uid = store.state.UserState.user?.id
        {
            goal.follow[index].members[uid] = sender.isOn ? Date().toMillis() : -1
            
        }
        store.dispatch(UpdateGoalAction(goal: goal))
        updatePieChartData()
        self.tableView.reloadData()
        
    }
}
