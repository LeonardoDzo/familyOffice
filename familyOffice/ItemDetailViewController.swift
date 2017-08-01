//
//  ItemDetailViewController.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/3/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {
    var item:ToDoList.ToDoItem!
    @IBOutlet var itemTitle: UILabel!
    @IBOutlet var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(title: "Editar", style: .plain, target: self, action: #selector(handleEdit))
        self.navigationItem.rightBarButtonItem = saveButton

        itemTitle.text = item.title
        image.loadImage(urlString: item.photoUrl!)
        // Do any additional setup after loading the view.
    }
    
    func handleEdit() -> Void {
        self.performSegue(withIdentifier: "editItemSegue", sender: nil)
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
