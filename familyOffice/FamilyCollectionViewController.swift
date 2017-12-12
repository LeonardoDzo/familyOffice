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
import ReSwift

private let reuseIdentifier = "cell"

class FamilyCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate  {
    @IBOutlet weak var mainView: UIView!
    var families : Results<FamilyEntity>!
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

    
    func initialConf() -> Void {
        let lpgr = UILongPressGestureRecognizer(target: self, action:#selector(handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.familyCollection.addGestureRecognizer(lpgr)
        style_1()
        
        self.familyCollection.layer.cornerRadius = 8
        self.familyCollection.clipsToBounds = true
        families = rManager.realm.objects(FamilyEntity.self)
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
            self.pushToView(view: .profileFamily, sender: families[indexPath.row])
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
extension FamilyCollectionViewController: StoreSubscriber {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.subscribe(self) {
            subcription in
            subcription.select { state in state.FamilyState }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: FamilyState) {
        self.view.hideToastActivity()
        switch state.status {
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            families = rManager.realm.objects(FamilyEntity.self)
            self.familyCollection.reloadData()
            break
        case .Finished(let action as FamilyAction) :
            if case FamilyAction.delete(_) = action {
                self.familyCollection.reloadData()
            }
            break
        default:
            break
        }
        
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        let point: CGPoint = gestureReconizer.location(in: self.familyCollection)
        let indexPath = self.familyCollection?.indexPathForItem(at: point)
        
        if (indexPath != nil && (indexPath?.row)! < families.count) {
            switch gestureReconizer.state {
            case .began:
                let family = families[(indexPath?.row)!]
                
                // create the alert
                let alert = UIAlertController(title: family.name, message: "¿Qué deseas hacer?", preferredStyle: UIAlertControllerStyle.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Seleccionar", style: UIAlertActionStyle.default, handler: {action in
                        self.toggleSelect(family: family)
                }))
                alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel, handler: nil))
                
                alert.addAction(UIAlertAction(title: "Eliminar", style: UIAlertActionStyle.destructive, handler:  { action in
                    
                        self.togglePendingDelete(family: family)
                        //self.collectionView?.deleteItems(at: [indexPath!])
                }))
                // show the alert
                self.present(alert, animated: true, completion: nil)
                break
            case .ended:
                break
            default:
                break
            }
        }
    }
    
    func toggleSelect(family: FamilyEntity){
        store.dispatch(UserS(.selectFamily(family: family)))
    }
    
    func togglePendingDelete(family: FamilyEntity) -> Void
    {
        store.dispatch(FamilyS(.delete(fid: family.id)))
    }
    
    
    
}


