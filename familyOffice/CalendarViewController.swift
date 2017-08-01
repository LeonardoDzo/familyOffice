//
//  CalendarViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 23/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import UIKit
import FSCalendar

class CalendarViewController: UIViewController, UIGestureRecognizerDelegate {

    var dates: [Event] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
    
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.scope = .week
        self.calendar.formatView()
        self.tableView.formatView()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleNew))
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        self.navigationItem.rightBarButtonItem = addButton
        self.calendar.accessibilityIdentifier = "calendar"
        
    }
    func tapFunction(sender: UILabel) {
        let center = sender.center
        let point = sender.superview!.convert(center, to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        let cell = self.tableView.cellForRow(at: indexPath!) as! EventTableViewCell
       
        self.performSegue(withIdentifier: "showEventSegue", sender: cell.event)
        
    }
    func handleNew() {
        self.performSegue(withIdentifier: "addSegue", sender: Event())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.calendar.select(Date())
        self.tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    func gotoView(event: Event, segue: String){
        
    }
    deinit {
        print("\(#function)")
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueString = segue.identifier else {
            return
        }
        switch segueString {
        case "showEventSegue":
            //let viewController = segue.destination as! ShowEventViewController
            //viewController.bind(event: self.event)
            break
        case "addSegue":
            let viewController = segue.destination as! addEventTableViewController
            if sender is Event {
                viewController.bind(sender as! Event)
            }
            
            break
        default: break
            
        }
       
    }
}

extension CalendarViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        let date = dates[indexPath.row]
        cell.bind(event: date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? EventTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.calendar.setScope(.week, animated: true )
        self.calendar.layoutIfNeeded()
        self.calendar.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let cell = tableView.cellForRow(at: editActionsForRowAt) as! EventTableViewCell
        
        let more = UITableViewRowAction(style: .normal, title: "Ver mas") { action, index in
            
            self.performSegue(withIdentifier: "showEventSegue", sender: cell.event)
        }
      
        let edit = UITableViewRowAction(style: .default, title: "Editar") { action, index in
       
            self.performSegue(withIdentifier: "addEventSegue", sender: cell.event)
            print("favorite button tapped")
        }
        
        edit.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        
        let share = UITableViewRowAction(style: .destructive, title: "Eliminar") { action, index in
            print("share button tapped")
        }
        
        return [share, edit, more]
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    //Select cell of Calendar
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        tableView.reloadData()
    }
    //Change Page Calendar
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let number : UInt32 = arc4random_uniform(2)
        return Int(number)
    }
    
}

