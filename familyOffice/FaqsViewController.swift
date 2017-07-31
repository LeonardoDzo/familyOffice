//
//  FaqsViewController.swift
//  familyOffice
//
//  Created by miguel reina on 16/07/17.
//  Copyright © 2017 Miguel Reina. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class FaqsTableViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, UITabBarDelegate{
    
    @IBOutlet var tableView: UITableView!
    
    let sections: [String] = ["Chat", "Calendario", "Objetivos", "Galería", "Caja Fuerte", "Contactos","Botiquín","Inmuebles", "Salud", "Seguros", "Presupuesto", "Lista de Tareas","FAQs"]
    let icons = ["chat", "calendar", "objetives", "gallery","safeBox", "contacts", "firstaid","property", "health","seguro-purple", "presupuesto", "todolist", "faqs"]
    
    var questions: [Question] = []
    var user = store.state.UserState.user
    var cellSelected = -1
    
    let settingLauncher = SettingLauncher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName:#colorLiteral(red: 0.2848778963, green: 0.2029544115, blue: 0.4734018445, alpha: 1)]
        self.navigationItem.title = "FAQs"
        
        setupNavBar()
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //configuration()
    }
    
    func setupNavBar(){
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleNew))
        addButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        
        self.navigationItem.rightBarButtonItems = [ addButton]
        
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func handleMore(_ sender: Any) {
        settingLauncher.showSetting()
    }
    func handleNew() -> Void {
        self.performSegue(withIdentifier: "addSegue", sender: nil)
    }
    
    func back() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - TableView wrande
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.sections.count*2)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == cellSelected - 1 {
            cellSelected = -1
        }else{
            cellSelected = indexPath.row + 1
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FAQSectionCell", for: indexPath) as! FAQSectionCell
            cell.sectionNameLbl.text = self.sections[indexPath.row/2].uppercased()
            cell.iconImg.image = UIImage(named: icons[indexPath.row/2])
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionQuestionsCell", for: indexPath) as! SectionQuestionsCell
        cell.questions = getQuestions(at: indexPath)
        cell.segueDelegate = self
        cell.questionsTableView.reloadData()
        cell.setHeight()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return UITableViewAutomaticDimension
        }else{
            if indexPath.row == cellSelected {
                let count = getQuestions(at: indexPath).count
                
                return CGFloat(count * 44)
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func getQuestions(at indexPath: IndexPath) -> [Question]{
        let index = indexPath.row % 2 == 0 || indexPath.row == 0 ? indexPath.row/2 : (indexPath.row-1)/2
        return self.questions.filter({$0.subject == sections[index]})
    }
    
}

extension FaqsTableViewController: StoreSubscriber, Segue {
    func newState(state: FaqState) {
        user = store.state.UserState.user
        questions = state.questions[(user?.familyActive!)!] ?? []
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addObservers()
        store.subscribe(self){
            subscription in subscription.FaqState
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.state.FaqState.status = .none
        store.unsubscribe(self)
        service.FAQ_SERVICE.removeHandles()
    }
    
    func addObservers() -> Void {
        service.FAQ_SERVICE.initObservers(ref: "faq/\((user?.familyActive!)!)", actions: [.childAdded, .childRemoved, .childChanged])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "questionDetails"{
            let questionDetailsC = segue.destination as! QuestionDetailsViewController
            questionDetailsC.question = sender as! Question
            
        }
    }
    
    func selected(_ segue: String, sender: Any?) {
        self.performSegue(withIdentifier: segue, sender: sender)
    }
}
