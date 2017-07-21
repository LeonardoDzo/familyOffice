//
//  FamilyCollectionExtension.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 07/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Toast_Swift
import FirebaseAuth
import ReSwift
extension FamilyCollectionViewController: StoreSubscriber {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.subscribe(self) {
            state in
            state.FamilyState
        }
        if (store.state.UserState.user?.families?.count == 0){
            self.performSegue(withIdentifier: "editSegue", sender: nil)
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
        default:
            break
        }
        families = state.families.items
        self.familyCollection.reloadData()
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
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
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                        self.toggleSelect(family: family)
                        
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel, handler: nil))
                if(family.admin == FIRAuth.auth()?.currentUser?.uid){
                    alert.addAction(UIAlertAction(title: "Eliminar", style: UIAlertActionStyle.destructive, handler:  { action in
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                            self.togglePendingDelete(family: family)
                            //self.collectionView?.deleteItems(at: [indexPath!])
                        }
                        
                    }))
                }
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
    
    func toggleSelect(family: Family){
       service.USER_SVC.selectFamily(family: family)
    }
    
    func togglePendingDelete(family: Family) -> Void
    {
        store.dispatch(DeleteFamilyAction(fid: family.id))
    }
    


}
