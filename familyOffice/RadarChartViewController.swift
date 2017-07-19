//
//  RadarChartViewController.swift
//  familyOffice
//
//  Created by Nan Montaño on 17/jul/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Charts

class RadarChartViewController: UIViewController, ChartViewDelegate, IAxisValueFormatter, IValueFormatter {
    
    var selectedEntry : ChartDataEntry?
    var radarXAxisValues: [String] = []
    var data = [RadarChartDataEntry]()
    let formatter = NumberFormatter()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        guard let radarChart = view as? RadarChartView else { return }
        
        radarChart.delegate = self
        radarChart.rotationEnabled = false
//        radarChart.yAxis.valueFormatter = self
        radarChart.yAxis.axisMinimum = 0
        radarChart.chartDescription?.enabled = false
        radarChart.xAxis.valueFormatter = self
        radarChart.legend.enabled = false
        
        
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_MX")

    }
    
    func setData(concepts: [BudgetConcept]){
        
        guard let radarChart = view as? RadarChartView else { return }
        
        data = []
        radarXAxisValues = []
        
        concepts.forEach({
            if $0.amount >= 0 { return }
            if let index = radarXAxisValues.index(of: $0.name) {
                data[index].value += $0.amount
            } else {
                data.append(RadarChartDataEntry(value: -$0.amount))
                radarXAxisValues.append($0.name)
            }
        })
        
        let conceptsSet = RadarChartDataSet(values: data, label: nil)
        conceptsSet.drawFilledEnabled = true
        conceptsSet.fillColor = UIColor.cyan
        conceptsSet.fillAlpha = 0.3
        conceptsSet.valueFormatter = self
        
        radarChart.data = RadarChartData(dataSet: conceptsSet)
        radarChart.notifyDataSetChanged()
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
        let index = Int(value) % radarXAxisValues.count
        return radarXAxisValues[index]
    }
    
    // MARK: IValueFormatter
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if(selectedEntry != entry) {
            return ""
        }
        let money = value as NSNumber
        return formatter.string(from: money)!
    }
    
    
    
}
