//
//  CalendarOpenViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 12/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import JBDatePicker

class CalendarOpenViewController: UIViewController,
JBDatePickerViewDelegate{

    weak var dateDelegate: DateProtocol!
    @IBOutlet weak var datePickerView: JBDatePickerView!
    var dateToSelect: Date!
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerView.delegate = self
        self.navigationItem.title = datePickerView.presentedMonthView?.monthDescription
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
       
    }
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    
    func didSelectDay(_ dayView: JBDatePickerDayView) {
        if dateDelegate != nil {
            dateDelegate.selectedDate(date: dayView.date!)
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func didPresentOtherMonth(_ monthView: JBDatePickerMonthView) {
        self.navigationItem.title = datePickerView.presentedMonthView.monthDescription
        
    }

    @IBAction func dismissDatePicker(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
