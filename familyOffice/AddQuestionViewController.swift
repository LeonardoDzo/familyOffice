//
//  AddQuestionViewController.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/26/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift

class AddQuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    var questions: [Question] = []
    
    let user = store.state.UserState.user
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var questionTextField: UITextField!
    @IBOutlet var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        sendButton.tintColor = #colorLiteral(red: 1, green: 0.04677283753, blue: 0, alpha: 1)
        tableView.separatorStyle = .none
        
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cQuestionCell", for: indexPath) as! CQuestionCell
            cell.cQuestionLbl.text = self.questions[indexPath.row/2].question //lol x 2
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cResponseCell", for: indexPath) as! CResponseCell
        cell.cResponseLbl.text = self.questions[indexPath.row/2].answer //lol x 3
        cell.isHidden = (cell.cResponseLbl.text?.isEmpty)!
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.questions.count*2)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.questions[indexPath.row/2].answer?.isEmpty)! && indexPath.row % 2 != 0 {
            return 0
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: - Button
    
    @IBAction func sendQuestion(_ sender: UIButton) {
        let q = questionTextField.text
        if (q?.isEmpty)! || q == nil{
            service.ANIMATIONS.shakeTextField(txt: questionTextField)
            return
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy"
        let result = formatter.string(from: date)
        
        let question = Question(question: q!, answer: "", subject: "Asistente", date: result, isPrivate: true)
        
        store.dispatch(InsertFaqAction(question: question))
        
        questionTextField.text = ""
    }
    

    
    // MARK: - Keyboard

    func keyboardWillShow(notification: Notification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: Notification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    // MARK: - GestureRecognizer
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view != self.sendButton
    }
 

}

extension AddQuestionViewController: StoreSubscriber {
    func addObservers() -> Void {
        service.FAQ_SERVICE.initObservers(ref: "faq/\((user?.familyActive!)!)", actions: [.childAdded, .childRemoved, .childChanged])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addObservers()
        store.subscribe(self){
            subcription in
            subcription.select { state in state.FaqState}
        }
        NotificationCenter.default.addObserver(self, selector: #selector(AddQuestionViewController.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddQuestionViewController.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        let lastIndex = IndexPath(item: (self.questions.count*2)-1, section: 0)
        tableView.scrollToRow(at: lastIndex, at: UITableViewScrollPosition.top, animated: false)
        
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
            let lastIndex = IndexPath(item: (self.questions.count*2)-1, section: 0)
            tableView.scrollToRow(at: lastIndex, at: UITableViewScrollPosition.top, animated: true)
            break
        case .none:
            break
        default:
            break
        }
        
        questions = state.questions[(user?.familyActive)!]?.filter({$0.subject == "Asistente"}) ?? []
        
    }
}
