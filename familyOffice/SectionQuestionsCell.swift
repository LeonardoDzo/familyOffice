//
//  SectionQuestionsCell.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/25/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class SectionQuestionsCell: UITableViewCell {
    var questions: [Question] = []

    @IBOutlet var questionsTableView: UITableView!
    @IBOutlet var cellHeight: NSLayoutConstraint!
    
    weak var segueDelegate: Segue!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        setTableViewDSDelegate()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTableViewDSDelegate(){
        questionsTableView.delegate = self
        questionsTableView.dataSource = self
        questionsTableView.tag = self.tag
        questionsTableView.reloadData()
    }
    
    func setHeight() -> Void {
        cellHeight.constant = CGFloat(self.questions.count * 50)
        print(CGFloat(self.questions.count * 50))
    }
}

extension SectionQuestionsCell: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! QuestionCell
        let question = self.questions[indexPath.row]
        cell.questionLbl.text = question.question.uppercased() //lol
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let question = questions[indexPath.row]
        segueDelegate.selected("questionDetails", sender: question)
    }
}
