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
import ReSwift
class HomeViewController: UIViewController,UIGestureRecognizerDelegate {
    
    
    let icons = ["chat", "calendar", "objetives", "gallery","safeBox", "contacts", "firstaid","property", "health","seguro-purple", "presupuesto", "todolist", "faqs"]
    let labels = ["Chat", "Calendario", "Objetivos", "Galería", "Caja Fuerte", "Contactos","Botiquín","Inmuebles", "Salud", "Seguros", "Presupuesto", "Lista de Tareas","FAQs"]

    
    
    private var family : Family?
    
    var user = store.state.UserState.user
    var families = [Family]()
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var modalAlert: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundButton: UIButton!
    
    
    var navigationBarOriginalOffset : CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
        }
        self.backgroundButton.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.titleLabel.textColor = #colorLiteral(red: 0.934861362, green: 0.2710093558, blue: 0.2898308635, alpha: 1)
        self.titleLabel.textAlignment = .left
        descriptionLabel.textColor = #colorLiteral(red: 0.2941176471, green: 0.1764705882, blue: 0.5019607843, alpha: 1)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        setupConfigurationNavBar()
    }
    lazy var settingLauncher : SettingLauncher = {
        let launcher = SettingLauncher()
        return launcher
    }()
    
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
        self.dismiss(animated: true, completion: nil)
    }
    
    /** ESTA FUNCION NOMAS PONE OBSERVERS */
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            subcription in
            subcription.select { state in state.FamilyState }
        }
        reloadFamily()
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
        store.unsubscribe(self)
    }
    
    @IBOutlet weak var selectItem: MIBadgeButton!
    @IBAction func selectedItem(_ sender: UIButton) {
        gotoModule(index: sender.tag)
    }
    
    
    
}
extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    
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
        let value = store.state.notifications.filter({$0.type == Notification_Type(rawValue: indexPath.item)}).count
        if value > 0 {
            cell.buttonicon.badgeString = String(value)
            cell.buttonicon.badgeEdgeInsets = UIEdgeInsetsMake(10, 10, 0, 0)
            cell.buttonicon.badgeBackgroundColor = UIColor.red
        }
        
        cell.buttonicon.tag = indexPath.item
        return cell
    }
    
    func reloadFamily() -> Void {
        if let index = families.index(where: {$0.id == user?.familyActive}) {
            let family = families[index]
            self.navigationItem.title = family.name
        }
    }
    
}
extension HomeViewController {

    func handleMore(_ sender: Any) {
        settingLauncher.showSetting()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        gotoModule(index: (indexPath.item))
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
        case 5:
            self.performSegue(withIdentifier: "contactsSegue", sender: nil)
        case 6:
            self.performSegue(withIdentifier: "showFirstAidKit", sender: nil)
        case 8:
            self.performSegue(withIdentifier: "healthSegue", sender: nil)
            break
        case 10:
            self.performSegue(withIdentifier: "budgetSegue", sender: nil)
        case 11:
            self.performSegue(withIdentifier: "todolistSegue", sender: nil)
        case 12:
            self.performSegue(withIdentifier: "faqsSegue", sender: nil)
        default:
            break
        }
        
    }
    func setupConfigurationNavBar() -> Void {
     
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_more_button"), style: .plain, target: self, action:  #selector(self.handleMore(_:)))
        let valueButton = UIBarButtonItem(image: #imageLiteral(resourceName: "value"), style: .plain, target: self, action:  #selector(self.handleShowModal(_:)))
        
        self.navigationItem.rightBarButtonItems = [ moreButton,valueButton]
        let barButton = UIBarButtonItem(title: "Regresar", style: .plain, target: self, action: #selector(self.handleBack))
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        self.navigationItem.leftBarButtonItem = barButton
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.3137395978, green: 0.1694342792, blue: 0.5204931498, alpha: 1)]
    }
    
}

extension HomeViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = FamilyState
    
    func newState(state: FamilyState) {
        user = store.state.UserState.user
        
        families = state.families.items
        if families.count == 0 {
            self.handleBack()
        }
        reloadFamily()
        
        
    }

}
