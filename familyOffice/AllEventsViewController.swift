//
//  AllEventsViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 05/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift
class AllEventsViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    var events : Results<EventEntity>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendar.select(calendar.today, scrollToDate: true)
        calendar(calendar, didSelect: Date(), at: .next)
        calendar.setCurrentPage(calendar.today!, animated: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.calendar.reloadData()
        self.tabBarController?.navigationItem.title = "Todos los Eventos"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
}
extension AllEventsViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events != nil ?  events.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventCell
        let event = events[indexPath.row]
        cell.bind(sender: event)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        self.pushToView(view: .eventDetails, sender: event)
    }
}
extension AllEventsViewController : FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.events = getEvents(date: date)
        if self.events.count == 0 {
            let imageView = UIImageView()
            imageView.image = #imageLiteral(resourceName: "background_no_events")
            tableView.backgroundView = imageView
            imageView.contentMode = .scaleAspectFill
        }else{
            self.tableView.backgroundView = UIView()
        }
        tableView.tableFooterView = UIView()
        self.tableView.reloadData()
    }
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(calendar.currentPage.string(with: .MMddyyyy))")
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return getEvents(date: date).count
    }
    
    func getEvents(date: Date) -> Results<EventEntity>! {
        let todayDate =  Date(string: date.string(with: .ddMMMyyyy), formatter: .ddMMMyyyy)
        let today = todayDate?.toMillis()
        let todayend = todayDate?.addingTimeInterval(23*60*60).toMillis()
        return rManager.realm.objects(EventEntity.self).filter("startdate >= %@ AND startdate <= %@",today ?? 0, todayend ?? 0)
    }
}
