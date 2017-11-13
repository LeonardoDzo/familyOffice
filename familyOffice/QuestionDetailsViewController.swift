//
//  QuestionDetailsViewController.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/27/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class QuestionDetailsViewController: UIViewController {
    
    @IBOutlet var questionLbl: UILabel!
    @IBOutlet var answerLbl: UILabel!
    @IBOutlet var answerWrapperView: UIView!
    
    var question: Question!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSAttributedStringKey.foregroundColor:#colorLiteral(red: 0.2848778963, green: 0.2029544115, blue: 0.4734018445, alpha: 1)]
        self.navigationItem.title = "FAQs/\(question.subject!)"
        
        self.questionLbl.layer.borderWidth = 1
        self.questionLbl.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.questionLbl.layer.cornerRadius = 5
        
        self.answerWrapperView.layer.borderWidth = 1
        self.answerWrapperView.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.answerWrapperView .layer.cornerRadius = 5
        
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        
        questionLbl.text = question.question //lol x4 
        answerLbl.text = question.answer //makes sense 4 me
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
