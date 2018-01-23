//
//  TopViewProfileAssistant.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 18/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import Foundation
import Stevia
import Charts
import RealmSwift

class ProfileAssistantStevia: UIViewX {
    var topview = TopViewProfileAssistant()
    var pieChart: PieChartView! = PieChartView()
    var pendings: Results<PendingEntity>!
    var notificationToken: NotificationToken? = nil
    convenience init() {
        self.init(frame:CGRect.zero)
        // This is only needed for live reload as injectionForXcode
        // doesn't swizzle init methods.
        // Get injectionForXcode here : http://johnholdsworth.com/injection.html
        render()
    
    }
    
    func render() {
        
        // View Hierarchy
        // This essentially does `translatesAutoresizingMaskIntoConstraints = false`
        // and `addSubsview()`. The neat benefit is that
        // (`sv` calls can be nested which will visually show hierarchy ! )
        sv(
            topview,
            pieChart
        )
        layout(
            0,
            |topview.width(100%).height(45%)|,
            8,
            |-pieChart.width(100%).height(45%)-|,
            ""
        )
        pendings = rManager.realm.objects(PendingEntity.self)
        notificationToken = pendings.observe { [weak self] (_) in
            self?.topview.refreshData()
            self?.updatePieChartData()
        }
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
       
    }
    
    func updatePieChartData()  {
        self.pieChart.clear()
        let track = ["No terminadas", "Terminadas"]
        var entries = [PieChartDataEntry]()
       
  
        let values = [Double(pendings.filter("done = %@",false).count), Double(pendings.filter("done = %@",true).count)]
        
        for (index, value) in values.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = track[index]
            entries.append( entry)
        }
        
        // 3. chart setup
        let set = PieChartDataSet( values: entries, label: "Cuantas ha terminado.")
        // this is custom extension method. Download the code for more details.
        let colors: [UIColor] = [#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)]
        
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
        
        pieChart.chartDescription?.text = ""
        pieChart.centerText = "Tareas terminadas"
        pieChart.holeRadiusPercent = 0.5
        pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInCirc)
        pieChart.transparentCircleColor = UIColor.clear
        
    }
}
