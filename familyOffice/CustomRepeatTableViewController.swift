//
//  CustomRepeatTableViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 03/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class CustomRepeatTableViewController: UITableViewController {
    @IBOutlet weak var frequencyPicker: UIPickerView!
    @IBOutlet weak var eachPicker: UIPickerView!
    @IBOutlet weak var collectionDays: UICollectionView!
    var days = [String]()
    var active = -1
    weak var shareEvent: ShareEvent!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 || indexPath.row == 2 {
            if active == indexPath.row {
                active = -1
            }else{
                active = indexPath.row
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 1  {
                if active == 0 {
                    return 200
                }
                return 0.0
            } else if indexPath.row == 3 {
                if active == 2 {
                    return 200
                }
                return 0.0
            }
            return 44.0
        }else {
            if  shareEvent.event.repeatmodel.frequency != .daily  && shareEvent.event.repeatmodel.frequency != .never  {
                return collectionDays.frame.size.height
            }
            return 0
        }
    }
}
extension CustomRepeatTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.frequencyPicker {
            return 4
        }
        return 48
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.frequencyPicker {
            return frequency[row].0
        }
        return String((row + 1))
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == frequencyPicker {
            days.removeAll()
            /// val y el if evaluando el row se utitliza para verificar y no confundin con monthly y weekly de el enum frequency
            var val = 1
            if row == 2 {
                val = 2
            }
            shareEvent.event.repeatmodel.frequency = Frequency(rawValue: val)
            shareEvent.event.repeatmodel.days.removeAll()
            reloadDataREpeat(row: row)
            return
        }
        shareEvent.event.repeatmodel.interval = row+1
    }
    
}
extension CustomRepeatTableViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellDay", for: indexPath) as! dayCollectionViewCell
        cell.dayLbl.text = days[indexPath.row]
        if shareEvent.event.repeatmodel.days.contains(String(indexPath.row)) {
            cell.backgroundColor = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)
            cell.dayLbl.textColor = UIColor.white
        }else{
            cell.backgroundColor = UIColor.clear
            cell.dayLbl.textColor = UIColor.black
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let index = shareEvent.event.repeatmodel.days.index(where: {$0 == String(indexPath.row)}) {
            shareEvent.event.repeatmodel.days.remove(at: index)
        }else{
            shareEvent.event.repeatmodel.days.append(String(indexPath.row))
        }
        collectionDays.reloadData()
    }
    
    func reloadDataREpeat(row: Int) -> Void {
        if row == 1 {
            days = ["D","L","M","Mi","J","V","S"]
            collectionDays.allowsMultipleSelection = true
        }else if row == 2{
            for i in 1..<32 {
                days.append(String(i))
            }
            collectionDays.allowsMultipleSelection = false
        }else if row == 3 {
            days = ["Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"]
        }
        tableView.reloadData()
        collectionDays.reloadData()
    }
}
