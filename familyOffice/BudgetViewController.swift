//
//  BudgetViewController.swift
//  familyOffice
//
//  Created by Nan Montaño on 28/jun/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Charts

class BudgetViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let settingLauncher = SettingLauncher()
    var values: [BudgetConcept] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Aqui se leerian los datos de firebase para despues
        // construir los datos y llamar las funciones setData,
        // ademas de los valores para radarXAxisValues

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return values.count // lineChart + radarChart + tableHeaders + values
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 125, height: 32)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch(indexPath.section){
        case 0: /* tableHeaders */
            let tableHeader = collectionView
                .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BudgetCollectionViewCell
            tableHeader.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            switch(indexPath.row){
            case 0: tableHeader.label.text = "Concepto"; break
            case 1: tableHeader.label.text = "Cantidad"; break
            case 2: tableHeader.label.text = "Fecha"; break
            default: break
            }
            return tableHeader
            
        default: /* values */
            let index = indexPath.section
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BudgetCollectionViewCell
            cell.backgroundColor = values[index].amount > 0
                ? UIColor(red: 0, green: 1, blue: 0, alpha: 0.1)
                : UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
            switch(indexPath.row){
            case 0: cell.label.text = values[index].name; break
            case 1:
                let money = values[index].amount as NSNumber
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = Locale(identifier: "es_MX")
                cell.label.text = formatter.string(from: money)!;
                break
            case 2: cell.label.text = values[index].date.string(with: DateFormatter.dayMonthAndYear2)
            default: break
            }
            return cell
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
//    func setValues(){
//        radarXAxisValues = ["Comida", "Transporte", "Alojamiento", "Entretenimiento", "Hogar", "Otros"]
//        var currentBudget = Double(arc4random_uniform(30000))
//        var budget: [ChartDataEntry] = [ChartDataEntry(x: 0, y: currentBudget)]
//        var income: [ChartDataEntry] = [ChartDataEntry(x: 0, y: 0)]
//        var discharges: [ChartDataEntry] = [ChartDataEntry(x: 0, y: 0)]
//        var conceptValues: [Double] = [0,0,0,0,0,0]
//        for i in 1 ..< 12 {
//            let _in : Double = Double(arc4random_uniform(10000))
//            let _out: Double = Double(arc4random_uniform(10000))
//            income.append(ChartDataEntry(x: Double(i), y: _in))
//            discharges.append(ChartDataEntry(x: Double(i), y: _out))
//            
//            let conceptIndex : Int = i%6
//            conceptValues[conceptIndex] += _out
//            
//            currentBudget += _in - _out
//            budget.append(ChartDataEntry(x: Double(i), y: currentBudget))
//            
//        }
//        
//        var concepts: [RadarChartDataEntry] = []
//        for i in 0 ..< conceptValues.count {
//            let val = conceptValues[i]
//            concepts.append(RadarChartDataEntry(value: val))
//        }
//        print("asdbakjsbdkjasbd", concepts);
//        setData(lineChart: lineChart, budget: budget, income: income, discharges: discharges)
//        setData(radarChart: radarChart, concepts: concepts)
//    }
    
    
}
