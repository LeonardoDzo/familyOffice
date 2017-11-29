//
//  FamilyCollectionViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 19/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift
import RealmSwift

private let reuseIdentifier = "cell"

class FamilyCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate  {
    @IBOutlet weak var mainView: UIView!
    var families : Results<FamilyEntitie>!
    typealias StoreSubscriberStateType = FamilyState
    //Internal var
    var indexP : IndexPath? = nil
    var longPressTarget: (cell: UICollectionViewCell, indexPath: IndexPath)?
    //UI
    @IBOutlet var familyCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConf()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="changeScreen" {
            let viewController = segue.destination as! FamilyViewController
            if sender is Family {
                viewController.bind(fam: sender as! Family)
            }
        }
    }
    
    func initialConf() -> Void {
        let lpgr = UILongPressGestureRecognizer(target: self, action:#selector(handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.familyCollection.addGestureRecognizer(lpgr)
        style_1()
        
        self.familyCollection.layer.cornerRadius = 8
        self.familyCollection.clipsToBounds = true
        families = rManager.realm.objects(FamilyEntitie.self)
        self.mainView.formatView()
        
    }
       
}


extension FamilyCollectionViewController {
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == families.count){
            
        }else{
            self.performSegue(withIdentifier: "changeScreen", sender: families[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return families.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Family Cell
        if indexPath.row < families.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FamiliesPreCollectionViewCell
            let family = families[indexPath.item]
            cell.bind(fam: family)
            return cell
        }
        //Add Cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as! addCell
        return cell
    }
    
   
}


