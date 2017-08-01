//
//  LineChartViewController.swift
//  familyOffice
//
//  Created by Nan Montaño on 17/jul/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Charts

class LineChartViewController: UIViewController, ChartViewDelegate, IAxisValueFormatter, IValueFormatter {
    
    var values = [BudgetConcept]()
    var selectedEntry : ChartDataEntry?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let lineChart = view as? LineChartView else { return }
        // Do any additional setup after loading the view.
        lineChart.delegate = self
        lineChart.dragEnabled = true
        lineChart.pinchZoomEnabled = true
        lineChart.drawGridBackgroundEnabled = true
        lineChart.gridBackgroundColor = UIColor.white
        lineChart.chartDescription?.enabled = false
        lineChart.doubleTapToZoomEnabled = false
        lineChart.xAxis.valueFormatter = self
        lineChart.xAxis.granularity = 1
        lineChart.zoom(scaleX: 2, scaleY: 1, x: 0, y: 0)
        lineChart.leftAxis.valueFormatter = self
        lineChart.rightAxis.valueFormatter = self
        //lineChart.rightAxis.enabled = false
    }
    
    func setData(concepts: [BudgetConcept], initialBudget: Double = 0){
        
        var budget : [ChartDataEntry] = [ChartDataEntry(x: 0, y: initialBudget)]
        var income : [ChartDataEntry] = [ChartDataEntry(x: 0, y: 0)]
        var discharges : [ChartDataEntry] = [ChartDataEntry(x: 0, y: 0)]
        
        for i in 1..<12 {
            budget.append(ChartDataEntry(x: Double(i), y: 0))
            income.append(ChartDataEntry(x: Double(i), y: 0))
            discharges.append(ChartDataEntry(x: Double(i), y: 0))
        }
        
        let calendar = Calendar.current
        concepts.forEach({
            let month = calendar.component(.month, from: $0.date)-1
            if($0.amount > 0){
                income[month].y += $0.amount
                //discharges.append(ChartDataEntry(x: month, y: 0))
            } else {
                discharges[month].y +=  -$0.amount
                //income.append(ChartDataEntry(x: month, y: 0))
            }
            budget[month].y += $0.amount
        })
        
        let budgetSet = LineChartDataSet(values: budget, label: "Presupuesto")
        let incomeSet = LineChartDataSet(values: income, label: "Ingresos")
        let dischargesSet = LineChartDataSet(values: discharges, label: "Egresos")
        
        let font = UIFont.systemFont(ofSize: 12)
        
        budgetSet.setColor(UIColor.cyan)
        budgetSet.circleColors = [UIColor.cyan]
        budgetSet.mode = .horizontalBezier
        budgetSet.valueFormatter = self
        budgetSet.drawFilledEnabled = true
        budgetSet.fillColor = UIColor.cyan
        budgetSet.fillAlpha = 0.3
        budgetSet.valueFont = font
        
        let green = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
        incomeSet.setColor(green)
        incomeSet.circleColors = [green]
        incomeSet.mode = .horizontalBezier
        incomeSet.valueFormatter = self
        incomeSet.valueFont = font
        
        dischargesSet.setColor(UIColor.red)
        dischargesSet.circleColors = [UIColor.red]
        dischargesSet.mode = .horizontalBezier
        dischargesSet.valueFormatter = self
        dischargesSet.valueFont = font
        
        guard let lineChart = view as? LineChartView else { return }
        lineChart.data = LineChartData(dataSets: [budgetSet, incomeSet, dischargesSet])
    }
    
    // MARK: ChartViewDelegate
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        selectedEntry = entry
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        selectedEntry = nil
    }
    
    // MARK: IAxisValueFormatter
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard value >= 0 else { return "" }
        guard let lineChart = view as? LineChartView else { return "wut"}
        if(lineChart.xAxis == axis){
            return ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago",
                    "Sep", "Oct", "Nov", "Dic"][Int(value) % 12]
        }
        if(lineChart.leftAxis == axis){
            let money = value as NSNumber
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "es_MX")
            return formatter.string(from: money)!
        }
        // right margin simulator
        return "        "
    }
    
    // MARK: IValueFormatter
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if(selectedEntry != entry) {
            return ""
        }
        let money = value as NSNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: money)!
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
