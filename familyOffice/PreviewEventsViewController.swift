//
//  PreviewEventsViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 04/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import RealmSwift

class PreviewEventsViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    var contentWith: CGFloat = 0.0
    var events : Results<EventEntity>!
    override func viewDidLoad() {
        scrollView.isPagingEnabled = true
        loadData()
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadData() -> Void {
        let backgroundnoevents = UIImageView(frame: self.view.frame)
        backgroundnoevents.tag = 100
        let todayDate =  Date(string: Date().string(with: .ddMMMyyyy), formatter: .ddMMMyyyy)
        let today = todayDate?.toMillis()
        let todayend = todayDate?.addingTimeInterval(23*60*60).toMillis()
        events = rManager.realm.objects(EventEntity.self).filter("startdate >= %@ AND startdate <= %@",today ?? 0, todayend ?? 0)
        
        if events != nil, events.count > 0 {
            scrollView.contentSize = CGSize(width: self.scrollView.bounds.width*CGFloat(events.count), height: self.scrollView.bounds.height)
            scrollView.showsHorizontalScrollIndicator = false
            pageControl.numberOfPages = events.count
            for i in 0..<events.count {
                let preevent = PreviewEvent.instanceFromNib() as! PreviewEvent
                let event = events[i]
                preevent.bind(sender: event)
                scrollView.addSubview(preevent)
                preevent.frame.size.width = self.view.bounds.width
                preevent.frame.origin.x = self.view.bounds.size.width * CGFloat(i)
            }
            if let view = self.view.viewWithTag(100) {
                view.removeFromSuperview()
            }
        }else{
           
            backgroundnoevents.image = #imageLiteral(resourceName: "background_no_events")
            self.view.addSubview(backgroundnoevents)
            backgroundnoevents.contentMode = .center
        }
        self.tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.view.reloadInputViews()
        loadData()
        self.tabBarController?.navigationItem.title = "Eventos de hoy"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
}
extension PreviewEventsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(page)
    }
}
extension PreviewEventsViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events != nil ? events.count : 0
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
