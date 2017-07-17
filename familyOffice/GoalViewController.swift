//
//  GoalViewContro/Users/ldurazo/Documents/proyectos/familyOffice/familyOffice/GoalViewController.swiftller.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Charts
import ReSwiftRouter
class GoalViewController: UIViewController, StoreSubscriber, UITabBarDelegate, GoalBindable {
    
    static let identifier = "GoalViewController"
    let settingLauncher = SettingLauncher()
    typealias StoreSubscriberStateType = GoalState
    var goal : Goal!
    var follow: FollowGoal!
    var user = store.state.UserState.user
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var tableView: UITableView!
    weak var axisFormatDelegate: IAxisValueFormatter?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        axisFormatDelegate = self
        pieChart.noDataText = "No hay objetivos"
    }
    @IBOutlet var dateForCompleate: UILabel!
    @IBOutlet weak var doneSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addObservers()
        
        self.bind()
        store.subscribe(self) {
            subscription in
            subscription.GoalsState
        }
        
        verifyFollow()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.state.GoalsState.status = .none
        store.unsubscribe(self)
        service.GOAL_SERVICE.removeHandles()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        configuration()
    }
    
    func setupNavBar(){
        let addButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.handleEdit))
        addButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        
        self.navigationItem.rightBarButtonItems = [ addButton]
        
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    
    func configuration() -> Void {
        addObservers()
        newState(state: store.state.GoalsState)
        tableView.reloadData()
    }
    
    func addObservers() -> Void {
        service.GOAL_SERVICE.initObserves(ref: "goals/\((user?.familyActive!)!)", actions: [ .childChanged])
        
    }
    
    func handleEdit() -> Void {
        self.performSegue(withIdentifier: "addSegue", sender: goal)
    }
    func back() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func newState(state: GoalState) {
        self.navigationItem.title = goal.title!
        switch state.status {
        case .Finished(let t as Goal):
            self.view.hideToastActivity()
            goal = t
            verifyFollow()
            store.state.GoalsState.status = .none
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        default:
            break
        }
        
    }
    func selectFamily() -> Void {
        if let index = store.state.FamilyState.families.index(where: {$0.id == store.state.UserState.user?.familyActive}){
            let family = store.state.FamilyState.families[index]
            self.navigationItem.title = family.name
        }
    }
    
    
    @IBAction func handleChange(_ sender: UISwitch) {
        
        if follow != nil, let index = goal.follow.index(where: {$0.date == follow.date}), let uid = store.state.UserState.user?.id
        {
            goal.follow[index].members[uid] = sender.isOn ? Date().toMillis() : -1
            
        }else{
            goal.members[(user?.id)!] = sender.isOn ? Date().toMillis() : -1
            
        }
        store.dispatch(UpdateGoalAction(goal: goal))
    }
    func updatePieChartData()  {
        self.pieChart.clear()
        let track = ["No", "Si"]
        var entries = [PieChartDataEntry]()
        let members = follow == nil ? self.goal.members : self.follow.members
        let goalMembers = [Double(members.filter({$0.value < 0}).count), Double(members.filter({$0.value > 0}).count) ]
        
        for (index, value) in goalMembers.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = track[index]
            entries.append( entry)
        }
        
        // 3. chart setup
        let set = PieChartDataSet( values: entries, label: "Cuantos la han logrado.")
        // this is custom extension method. Download the code for more details.
        let colors: [UIColor] = [#colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1),#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)]
        
        set.colors = colors
        let data = PieChartData(dataSet: set)
        pieChart.data = data
        pieChart.noDataText = "No existen objetivos"
        // user interaction
        pieChart.isUserInteractionEnabled = true
        let d = Description()
        pieChart.chartDescription = d
        pieChart.centerText = "Obj."
        pieChart.holeRadiusPercent = 0.5
        pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInCirc)
        pieChart.transparentCircleColor = UIColor.clear
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSegue" {
            let vc = segue.destination as! AddGoalViewController
            let goal :Goal!
            if sender is Goal {
                goal = sender as? Goal
                vc.bind(goal: goal)
            }
        }else if segue.identifier == "detailSegue" {
            let vc = segue.destination as! GoalHistoryByUserViewController
            
            vc.bind(goal: self.goal)
            if sender is User {
                vc.user = sender as! User
            }
        }
    }
}

extension GoalViewController: UITableViewDelegate, UITableViewDataSource, IAxisValueFormatter {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goal.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GoalTableViewCell
        let members = follow == nil ? self.goal.members : self.follow.members
        
        let key = Array(members.keys)[indexPath.row]
        let member = getUser(id: key) ?? nil
        cell.titleLbl.text = member != nil ? member?.name : "Cargando..."
        let date = follow != nil ? follow.members[key] ?? -1 : goal.members[key] ?? -1
        cell.endDateLbl.text = date > 0 ? Date(timeIntervalSince1970: TimeInterval(date/1000)).string(with: .dayMonthAndYear2) : "Sin capturar"
        cell.accessoryType = members[key]! > 0 ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let members = follow == nil ? self.goal.members : self.follow.members
        let key = Array(members.keys)[indexPath.row]
        let member = getUser(id: key) ?? nil
        if follow != nil {
            self.performSegue(withIdentifier: "detailSegue", sender: member)
        }
        
    }
    
    
    
    func getUser(id: String) -> User? {
        if let user =  store.state.UserState.users.first(where: {$0.id == id}) {
            return user
        }else if id == store.state.UserState.user?.id {
            return user
        }else{
            store.dispatch(GetUserAction(uid: id))
        }
        return nil
        
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if let family = store.state.FamilyState.families.first(where: {$0.id == user?.familyActive}) {
            let id = family.members[Int(value)]
            if let user = getUser(id: id){
                if user.id == store.state.UserState.user?.id {
                    return "Yo"
                }
                return user.name.components(separatedBy: " ")[0]
            }
        }
        return "none"
    }
}
extension GoalViewController {
    func verifyFollow() -> Void {
        
        let date = Date().toMillis()
        let follows = goal.follow.sorted(by: {$0.date < $1.date})
        for item in follows {
            let comp = Date(string: item.date, formatter: .ShortInternationalFormat)?.toMillis()
            if date! <= comp! {
                follow = item
                let string = "Fecha: "
                dateForCompleate.text = string + item.date
                break
            }
        }
        if follow != nil {
            doneSwitch.isOn = follow.members[(user?.id!)!]! > 0 ? true : false
        }else{
            doneSwitch.isOn = goal.members[(user?.id!)!]! > 0 ? true : false
            let string = "Finalizar objetivo de fecha: "
            dateForCompleate.text = string + Date(timeIntervalSince1970: TimeInterval(goal.endDate/1000)).string(with: .dayMonthAndYear2)
        }
        updatePieChartData()
        tableView.reloadData()
        
    }
    
}
