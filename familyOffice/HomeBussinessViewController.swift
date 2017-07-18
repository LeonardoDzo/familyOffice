//
//  HomeBussinessViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 23/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import Firebase
import UIKit

class HomeBussinessViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let icons = ["proyectos", "presupuesto", "politicas", "votacion"]
    let labels = ["Proyectos", "Presupuesto", "Políticas", "Votación"]
    
    
    private var family : Family?
    
    
    let user = service.USER_SERVICE.users.first(where: {$0.id == FIRAuth.auth()?.currentUser?.uid})
    var families : [String]! = []
    
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var navigationBarOriginalOffset : CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //USER_SERVICE.observers()
        let lpgr = UILongPressGestureRecognizer(target: self, action:#selector(handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0
        lpgr.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(lpgr)
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_more_button"), style: .plain, target: self, action:  #selector(self.handleMore(_:)))
        
        self.navigationItem.rightBarButtonItem = moreButton
        let barButton = UIBarButtonItem(title: "Atrás", style: .plain, target: self, action: #selector(self.handleBack))
        self.navigationItem.leftBarButtonItem = barButton
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.3137395978, green: 0.1694342792, blue: 0.5204931498, alpha: 1)]
        
    }
    
    let settingLauncher = SettingLauncher()
    
    func handleMore(_ sender: Any) {
        settingLauncher.showSetting()
    }
    
    
    func handleBack()  {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadFamily()
        
        
        if let index = service.FAMILY_SERVICE.families.index(where: {$0.id == service.USER_SERVICE.users[0].familyActive}) {
            self.navigationItem.title = service.FAMILY_SERVICE.families[index].name
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        NotificationCenter.default.addObserver(forName: notCenter.NOFAMILIES_NOTIFICATION, object: nil, queue: nil){ notification in
      
            return
        }
        NotificationCenter.default.addObserver(forName: notCenter.USER_NOTIFICATION, object: nil, queue: nil){_ in
            self.reloadFamily()
        }
        NotificationCenter.default.addObserver(forName: notCenter.FAMILYADDED_NOTIFICATION, object: nil, queue: nil){family in
            self.reloadFamily()
            //FAMILY_SERVICE.verifyFamilyActive(family: family.object as! Family)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //heightImg = familyImage.frame.size.height
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(notCenter.USER_NOTIFICATION)
        NotificationCenter.default.removeObserver(notCenter.NOFAMILIES_NOTIFICATION)
        NotificationCenter.default.removeObserver(notCenter.FAMILYADDED_NOTIFICATION)
    }
    
    func reloadFamily() -> Void {
     
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseInOut,animations: {
            cell.alpha = 1
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellModule", for: indexPath) as! ModuleCollectionViewCell
        
        cell.buttonicon.setBackgroundImage(UIImage(named: icons[indexPath.item])!, for: .normal)
        cell.name.text = labels[indexPath.row]
        cell.buttonicon.badgeString = "8"
        cell.buttonicon.badgeEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0)
        cell.buttonicon.badgeBackgroundColor = UIColor.red
        return cell
    }
    
    
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        let point: CGPoint = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView?.indexPathForItem(at: point)
        
        if (indexPath != nil ){
            switch gestureReconizer.state {
            case .began:
                gotoModule(index: (indexPath?.item)!)
                break
            case .ended:
                break
            default:
                break
            }
        }
    }
    
    func gotoModule(index: Int) -> Void {
    
        
    }

}
