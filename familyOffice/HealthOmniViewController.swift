//
//  HealthOmniViewController.swift
//  familyOffice
//
//  Created by Nan Montaño on 04/abr/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class HealthOmniViewController: UIViewController {
    
    @IBOutlet weak var membersCollectionView: UICollectionView!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet var categoryButtons: [UIButton]!
    
    var userIndex : Int = 0
    var categorySelected : Int = 0
    var elems : [Health.Element] = []
    
    // Members Extension
    var fam : Family!
    var membersId : [String] = []
    var membersObserver : NSObjectProtocol?
    var elementAddedObserver : NSObjectProtocol?
    var elementUpdatedObserver : NSObjectProtocol?
    var elementDeletedObserver : NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let editButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(edit(sender:)))
        navigationItem.rightBarButtonItem = editButton
        
        initElements()
        initMembers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        membersWillAppear()
        elementsWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        membersWillDisappear()
        elementsWillDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func edit(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editSegue", sender: self)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
    
}
