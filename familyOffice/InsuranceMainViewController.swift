//
//  InsuranceMainViewController.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazat on 12/18/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class InsuranceMainViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var filter: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        self.setStyle(.insurance)
        self.title = "Seguros"
        self.setupBack()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seeInsurances" {
            let insurancesController = segue.destination as! InsurancesViewController
            insurancesController.filter = self.filter
        }
    }
    

}

extension InsuranceMainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.filter = "cars"
            break
        case 1:
            self.filter = "homes"
            break
        case 2:
            self.filter = "medical"
            break
        case 3:
            self.filter = "life"
            break
        default:
            break
        }
        self.performSegue(withIdentifier: "seeInsurances", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "insuranceTypeCell", for: indexPath) as! InsuranceTypeCell
        
        switch indexPath.row {
        case 0:
            cell.image.image = #imageLiteral(resourceName: "insurances-cars")
            break
        case 1:
            cell.image.image = #imageLiteral(resourceName: "insurances-homes")
            break
        case 2:
            cell.image.image = #imageLiteral(resourceName: "insurances-med")
            break
        case 3:
            cell.image.image = #imageLiteral(resourceName: "insurances-lifes")
            break
        default:
            break;
        }
        return cell
    }
}
