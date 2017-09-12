//
//  PendingQuestionsTableViewController.swift
//  familyOffice
//
//  Created by Developer on 8/15/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift

class PendingQuestionsTableViewController: UITableViewController {
    var questions: [Question] = []
    let user = store.state.UserState.user

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pendingQuestionCell", for: indexPath) as! pendingQuestionCell
        
        cell.pendingQLabel.text = self.questions[indexPath.row].question
        cell.numberPQ.text = "\(indexPath.row + 1)"
        cell.numberPQ.layer.cornerRadius = 0.5 * cell.numberPQ.bounds.size.width

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Contestar", message: self.questions[indexPath.row].question, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { (_alert) in
            //Mandar la respuesta
            let answerTextField = alert.textFields?[0]
            
            self.questions[indexPath.row].answer = answerTextField?.text
            
            store.dispatch(UpdateFaqAction(question: self.questions[indexPath.row]))
        }))
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Respuesta"
        }
        
        present(alert, animated: true, completion: nil)
    }
    

}

extension PendingQuestionsTableViewController: StoreSubscriber {
    func addObservers() -> Void {
        service.FAQ_SERVICE.initObservers(ref: "faq/\((user?.familyActive!)!)", actions: [.childAdded, .childRemoved, .childChanged])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addObservers()
        store.subscribe(self){
            $0.select({
                s in s.FaqState
                })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.state.FaqState.status = .none
        store.unsubscribe(self)
        service.FAQ_SERVICE.removeHandles()
    }
    
    func newState(state: FaqState) {
        switch state.status {
        case .failed:
            self.view.makeToast("Ocurrió un error, intente nuevamente")
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            self.view.hideToastActivity()
            self.tableView.reloadData()
            break
        case .none:
            break
        default:
            break
        }
        
        questions = state.questions[(user?.familyActive)!]?.filter({$0.subject == "Asistente" && ($0.answer?.isEmpty)!}) ?? []
        
    }
    
}
