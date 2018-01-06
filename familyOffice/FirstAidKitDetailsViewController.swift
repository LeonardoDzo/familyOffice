//
//  FirstAidKitDetailsViewController.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazat on 1/5/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import UIKit

class FirstAidKitDetailsViewController: UIViewController {

    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var labels: [String] = []
    
    var illness: IllnessEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = illness.name
        
        self.descriptionLbl.text = illness.dosage

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        labels = illness.medicine.trimmingCharacters(in: .whitespaces).components(separatedBy: ",")
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

extension FirstAidKitDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "medicine", for: indexPath) as! MedicineTagCell
        cell.nameLbl.adjustsFontSizeToFitWidth = true
        cell.nameLbl.text = labels[indexPath.row].uppercased()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(text: self.labels[indexPath.row].uppercased())
        label.sizeToFit()
        let width = label.frame.width
        print("\(label.text), \(width)")
        return CGSize(width: width, height: 42)
    }
    
    
}
