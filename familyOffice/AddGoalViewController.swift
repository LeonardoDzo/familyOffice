//
//  AddGoalViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Toast_Swift
import Firebase
import ReSwift
import ReSwiftRouter

protocol DateProtocol: class {
    func selectedDate(date: Date) -> Void
}


class AddGoalViewController: UIViewController, GoalBindable, StoreSubscriber, UIGestureRecognizerDelegate, DateProtocol{
    static let identifier = "AddGoalViewController"
    var types = [("Deportivo","sport"),("Religión","religion"),("Escolar","school"),("Negocios","business-1"),("Alimentación","eat"),("Salud","health-1")]
    var mode = [("Diario","day"),("Semanal","week"),("Mensual","month")]
    var goal: Goal!
    var type = 0
    let padding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
    var days = [String]()
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var pickerSelect: UIPickerView!
    @IBOutlet weak var endDateLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionDays: UICollectionView!
    @IBOutlet weak var repeatSwitch: UISwitch!
    
    
    @IBAction func handleChange(_ sender: UITextField) {
        self.goal.title = self.titleTxt.text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        endDateLbl.layer.borderWidth = 1
        endDateLbl.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        endDateLbl.layer.cornerRadius = 4
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        tap.delegate = self
        endDateLbl.isUserInteractionEnabled = true
        endDateLbl.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    func tap(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        self.performSegue(withIdentifier: "toDatePicker", sender: nil)
    }
    func selectedDate(date: Date) {
        self.goal.endDate = date.toMillis()
        self.bind(goal: goal)
    }
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
        self.bind(goal: goal)
        if goal.id != nil{
            self.navigationItem.title = "Actualizar"
        }else{
            self.navigationItem.title = "Agregar"
        }
       
        store.subscribe(self) {
            state in
            state.GoalsState
        }
        
        if let index = mode.index(where: {$0.1 == goal.repeatGoalModel.mode}){
            repeatSwitch.isOn = true
            pickerSelect.isHidden = false
            pickerSelect.selectRow(index, inComponent: 0, animated: true)
            reloadDataREpeat(row: index)
        }else{
            repeatSwitch.isOn = false
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    @IBAction func handleChangeRepeat(_ sender: UISwitch) {
        if sender.isOn {
            pickerSelect.isHidden = false
            collectionDays.isHidden = false
            return
        }
        collectionDays.isHidden = true
        pickerSelect.isHidden = true
        
        
    }
    func setupNavBar(){
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.save))
        let updateButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.update))
        if goal.id != nil {
            self.navigationItem.rightBarButtonItem = updateButton
        }else{
            self.navigationItem.rightBarButtonItem = addButton
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func save() -> Void {
        
        guard let title = titleTxt.text, !title.isEmpty else {
            return
        }
        goal.setId()
        if goal.repeatGoalModel.mode.isEmpty {
            goal.repeatGoalModel.days.removeAll()
        }
        goal.title = title
        store.dispatch(InsertGoalAction(goal: goal))
    }
    
    func update() -> Void {
        
        guard let title = titleTxt.text, !title.isEmpty else {
            return
        }
        goal.title = title
        store.dispatch(UpdateGoalAction(goal: goal))
    }
    
    func newState(state: GoalState) {
        switch state.status {
        case .finished:
            self.view.hideToastActivity()
            _ = self.navigationController?.popViewController(animated: true)
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .none:
            break
        default: break
            
        }
    }
    
    typealias StoreSubscriberStateType = GoalState
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationNavController = (segue.destination as? UINavigationController){
            if let datePickerVC = destinationNavController.viewControllers.first as? CalendarOpenViewController{
                datePickerVC.dateToSelect = Date(string: endDateLbl.text!, formatter: .dayMonthAndYear2)
                datePickerVC.dateDelegate = self
                
            }
        }
    }
    
}
extension AddGoalViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return 6
        }
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView ==  self.collectionView {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! typeiconCollectionViewCell
            let obj = types[indexPath.row]
            cell.titleLbl.text = obj.0
            if goal.category == indexPath.item {
                cell.checkimage.backgroundColor = UIColor.clear
                cell.checkimage.alpha = 1
                cell.layer.borderWidth = 3.0
                cell.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
            }else{
                cell.checkimage.backgroundColor = UIColor.black
                cell.checkimage.alpha = 0.6
                cell.layer.borderWidth = 0.0
            }
            cell.photo.image = UIImage(named: obj.1)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellDay", for: indexPath) as! dayCollectionViewCell
            cell.dayLbl.text = days[indexPath.row]
            if goal.repeatGoalModel.days.contains(String(indexPath.row)) {
                cell.backgroundColor = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)
                cell.dayLbl.textColor = UIColor.white
            }else{
                cell.backgroundColor = UIColor.clear
                cell.dayLbl.textColor = UIColor.black
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            goal.category = indexPath.item
            collectionView.reloadData()
            return
        }
        if goal.repeatGoalModel.mode == "month" {
            goal.repeatGoalModel.days.removeAll()
        }
        if let index = goal.repeatGoalModel.days.index(where: {$0 == String(indexPath.row)}) {
            goal.repeatGoalModel.days.remove(at: index)
        }else{
            goal.repeatGoalModel.days.append(String(indexPath.row))
        }
        
        collectionDays.reloadData()
    }
    
}
extension AddGoalViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mode.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mode[row].0
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        days.removeAll()
        self.goal.repeatGoalModel.mode = mode[row].1
        self.goal.repeatGoalModel.days.removeAll()
        reloadDataREpeat(row: row)
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
        }
        collectionDays.reloadData()
    }
}


