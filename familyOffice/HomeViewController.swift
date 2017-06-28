//
//  HomeViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 05/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MIBadgeButton_Swift

class HomeViewController: UIViewController,  UIGestureRecognizerDelegate{
    
    let icons = ["chat", "calendar", "objetives", "gallery","safeBox", "contacts", "firstaid","property", "health","seguro-purple"]
    let labels = ["Chat", "Calendario", "Objetivos", "Galería", "Caja Fuerte", "Contactos","Botiquín","Inmuebles", "Salud", "Seguros"]
    
    
    private var family : Family?
    
    let user = service.USER_SERVICE.users.first(where: {$0.id == FIRAuth.auth()?.currentUser?.uid})
    var families : [String]! = []
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var modalAlert: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundButton: UIButton!
    
    
    var navigationBarOriginalOffset : CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundButton.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.titleLabel.textColor = #colorLiteral(red: 0.934861362, green: 0.2710093558, blue: 0.2898308635, alpha: 1)
        self.titleLabel.textAlignment = .left
        descriptionLabel.textColor = #colorLiteral(red: 0.2941176471, green: 0.1764705882, blue: 0.5019607843, alpha: 1)
        setupConfigurationNavBar()
    }
    
    let settingLauncher = SettingLauncher()
    
    @IBAction func handleCloseModal(_ sender: UIButton) {
        //UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.4,delay: 0.1, animations: {
                self.modalAlert.layer.position.x = 0 - self.modalAlert.frame.width/2
            })
            UIView.animate(withDuration: 0.4, delay: 0.4, animations: {
                //self.modalAlert.layer.position.x = self.modalAlert.layer.position.x * (-2)
                self.backgroundButton.alpha = 0
            })
        //})
        
    }
    
    func handleBack()  {
        service.UTILITY_SERVICE.gotoView(view: "mainView", context: self)
    }
    
    /** ESTA FUNCION NOMAS PONE OBSERVERS */
    override func viewWillAppear(_ animated: Bool) {
        reloadFamily()
        createObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //heightImg = familyImage.frame.size.height
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(notCenter.USER_NOTIFICATION)
        NotificationCenter.default.removeObserver(notCenter.NOFAMILIES_NOTIFICATION)
        NotificationCenter.default.removeObserver(notCenter.FAMILYADDED_NOTIFICATION)
    }
    
    
}
extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseInOut,animations: {
            cell.alpha = 1
        })
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
        cell.buttonicon.badgeEdgeInsets = UIEdgeInsetsMake(10, 10, 0, 0)
        cell.buttonicon.badgeBackgroundColor = UIColor.red
        
        return cell
    }
    
    func reloadFamily() -> Void {
        if service.USER_SERVICE.users.count > 0, let index = service.FAMILY_SERVICE.families.index(where: {$0.id == service.USER_SERVICE.users[0].familyActive}) {
            let family = service.FAMILY_SERVICE.families[index]
            
            self.navigationItem.title = family.name
        }
    }
    
}
extension HomeViewController {
    
    func createObservers() -> Void {
        if let index = service.FAMILY_SERVICE.families.index(where: {$0.id == service.USER_SERVICE.users[0].familyActive}) {
            self.navigationItem.title = service.FAMILY_SERVICE.families[index].name
        }
        
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
    func handleMore(_ sender: Any) {
        settingLauncher.setView(view: self)
        settingLauncher.showSetting()
    }
    func handleShowModal(_ sender: Any) -> Void {
        self.backgroundButton.backgroundColor = UIColor.black
        UIView.animate(withDuration: 0.3,delay: 0.3, animations: {
            self.backgroundButton.alpha = 0.65
        })
        UIView.animate(withDuration: 0.5,delay: 0.3, options: .curveEaseOut, animations: {
            //self.view.layoutIfNeeded()
            self.modalAlert.layer.position.x = self.view.frame.width/2
        }, completion: nil)
    }
    
    func gotoModule(index: Int) -> Void {
        switch index {
        case 0:
            self.performSegue(withIdentifier: "chatSegue", sender: nil)
            
        case 1:
            self.performSegue(withIdentifier: "calendarSegue", sender: nil)
        case 2:
            self.performSegue(withIdentifier: "goalSegue", sender: nil)
            break
        case 3:
            self.performSegue(withIdentifier: "gallerySegue", sender: nil)
            
        case 4:
            self.performSegue(withIdentifier: "safeBoxSegue", sender: nil)
            
        case 8:
            self.performSegue(withIdentifier: "healthSegue", sender: nil)
        default:
            break
        }
        
    }
    func setupConfigurationNavBar() -> Void {
        //USER_SERVICE.observers()
        let lpgr = UILongPressGestureRecognizer(target: self, action:#selector(handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0
        lpgr.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(lpgr)
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_more_button"), style: .plain, target: self, action:  #selector(self.handleMore(_:)))
        let valueButton = UIBarButtonItem(image: #imageLiteral(resourceName: "value"), style: .plain, target: self, action:  #selector(self.handleShowModal(_:)))
        
        self.navigationItem.rightBarButtonItems = [ moreButton,valueButton]
        let barButton = UIBarButtonItem(title: "Regresar", style: .plain, target: self, action: #selector(self.handleBack))
        
        barButton.tintColor = #colorLiteral(red: 1, green: 0.1757333279, blue: 0.2568904757, alpha: 1)
        self.navigationItem.leftBarButtonItem = barButton
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.3137395978, green: 0.1694342792, blue: 0.5204931498, alpha: 1)]
    }
    
}
