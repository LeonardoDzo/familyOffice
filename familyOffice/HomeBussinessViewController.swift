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
        style_1()
        
    }
    
    let settingLauncher = SettingLauncher()
    
    @objc func handleMore(_ sender: Any) {
        settingLauncher.showSetting()
    }
    
    
    @objc func handleBack()  {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadFamily()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //heightImg = familyImage.frame.size.height
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
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
