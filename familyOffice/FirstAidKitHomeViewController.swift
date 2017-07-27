//
//  FirstAidKitHomeViewController.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/20/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class FirstAidKitHomeViewController: UIViewController {
    let settingLauncher = SettingLauncher()
    
    
    @IBOutlet var medicinesBackground: UIImageView!

    @IBOutlet var illnessesBackground: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName:#colorLiteral(red: 0.2848778963, green: 0.2029544115, blue: 0.4734018445, alpha: 1)]
        self.navigationItem.title = "Botiquín"
        
        medicinesBackground.image = #imageLiteral(resourceName: "medicines-bg")
        illnessesBackground.image = #imageLiteral(resourceName: "illness-bg")
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        backButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_more_button"), style: .plain, target: self, action:  #selector(self.handleMore(_:)))
        moreButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        
        self.navigationItem.rightBarButtonItems = [moreButton]
        // Do any additional setup after loading the view.
    }
    
    //MARK :- Botones
    
    func back() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleMore(_ sender: Any) -> Void {
        settingLauncher.showSetting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func medicinesButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showMedicines", sender: nil)
    }
    
    
    @IBAction func IllnessesButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showIllnesses", sender: nil)
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
