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
    
    @IBOutlet weak var pieChart: PieChartView!
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func updatePieChartData()  {
        self.pieChart.clear()
        //let track = ["Comp.", "Incom.","Resto"]
        var entries = [PieChartDataEntry]()
        let sdata = values()
        for value in sdata {
            let entry = PieChartDataEntry()
            entry.y = Double(value)
            entries.append( entry)
        }
        
        // 3. chart setup
        let set = PieChartDataSet( values: entries, label: "")
        // this is custom extension method. Download the code for more details.
        let colors: [UIColor] = [#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1),#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)]
        
        set.colors = colors
        let data = PieChartData(dataSet: set)
        pieChart.data = data
        pieChart.noDataText = "No existen objetivos"
        // user interaction
        pieChart.isUserInteractionEnabled = true
        //pieChart.legend = Legend(entries: [])
        incompLbl.text = sdata[1].description
        completeLbl.text = sdata[0].description
        restLbl.text = sdata[2].description
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
        var isAlive = true
        let date = Date().toMillis()
        for item in goal.follow {
            let comp = Date(string: item.date, formatter: .ShortInternationalFormat)?.toMillis()
            if (date! <= comp! || date! >= comp!) && isAlive {
                if item.members[user.id]! > 0 {
                    count+=1
                }else{
                    incomplete+=1
                }
                isAlive = false
            }else {
                rest+=1
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
        cell.doneLbl.text = follow.members[user.id!]! > 0 ? getDate(follow.members[user.id!]!, with: .dayMonthAndYear2) : "Incompleta"
        if follow.members[user.id!]! > 0  {
            cell.doneLbl.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            cell.doneLbl.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }else{
            cell.doneLbl.backgroundColor = UIColor.clear
        }
        return cell
    }
}
