//
//  HomeCollectionViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 05/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
private let reuseIdentifier = "Cell"
import RealmSwift
class homesBtn {
    var image: UIImage!
    var color: UIColor!
    var segue = ""
    var type : Notification_Type! = .none
    init(_ img: UIImage, _ color: UIColor, _ segue: String, _ type : Notification_Type = .none) {
        self.image = img
        self.color = color
        self.segue = segue
        self.type = type
    }
}

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var notificationToken: NotificationToken? = nil
    var btnsArray = [homesBtn(#imageLiteral(resourceName: "Calendar"), #colorLiteral(red: 1, green: 0.2901960784, blue: 0.3529411765, alpha: 1),"calendarSegue",Notification_Type.event ), homesBtn(#imageLiteral(resourceName: "chat"), #colorLiteral(red: 0.01568627451, green: 0.7019607843, blue: 0.9960784314, alpha: 1), "chatSegue", Notification_Type.chat), homesBtn(#imageLiteral(resourceName: "safeBox"), #colorLiteral(red: 0.9607843137, green: 0.7215686275, blue: 0.1176470588, alpha: 1), "safeBoxSegue",Notification_Type.safebox), homesBtn(#imageLiteral(resourceName: "insurance"),#colorLiteral(red: 0.1137254902, green: 0.7176470588, blue: 0.4352941176, alpha: 1),"insuranceSegue", Notification_Type.insurance), homesBtn(#imageLiteral(resourceName: "FirstKit"), #colorLiteral(red: 0.5490196078, green: 0.5294117647, blue: 0.7843137255, alpha: 1),"firstAidKitSegue", Notification_Type.firstAidKit), homesBtn(#imageLiteral(resourceName: "asistance"), #colorLiteral(red: 0.9529411765, green: 0.5137254902, blue: 0.3529411765, alpha: 1),"assistant")]
    lazy var settingLauncher : SettingLauncher = {
        let launcher = SettingLauncher()
        return launcher
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.tabBarController?.tabBar.items?.last?.title = "Perfil"
        self.navigationController?.tabBarController?.tabBar.items?.last?.image = #imageLiteral(resourceName: "icons8-user_male")
       //r self.navigationController?.tabBarController?.tabBar.items?.last?.image = #imageLiteral(resourceName: "Setting")
        let changeFam = UIBarButtonItem(image: #imageLiteral(resourceName: "changeFam"), style: .plain, target: self, action: #selector(self.changefam))
        self.navigationItem.rightBarButtonItem = changeFam
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        let results = rManager.realm.objects(NotificationModel.self)
        notificationToken = results.observe { [weak self] (_ ) in
            self?.btnsArray.enumerated().forEach({ (i, _) in
                let cell = self?.collectionView?.cellForItem(at: IndexPath(item: i, section: 0)) as! homesCollectionViewCell
                cell.verifyNotifications(results)
            })
        }
    }
    
    @objc func changefam() -> Void {
         settingLauncher.showSetting()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return btnsArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! homesCollectionViewCell
        let btn = btnsArray[indexPath.row]
        cell.btn = btn
        cell.tag = indexPath.row
        cell.icon.image = btn.image
        cell.icon.backgroundColor = btn.color
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let btn = btnsArray[indexPath.row]
        if btn.segue == "assistant" {
            if rManager.getObjects(type: AssistantEntity.self)?.count == 0 {
                self.pushToView(view: .requestAssitant)
                return
            }
            
        }
        self.performSegue(withIdentifier: btn.segue, sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if btnsArray.count % 3 != 0, indexPath.item == btnsArray.count-1 {
            return CGSize(width: 100.0*2+20, height: 100.0)
        }
        
        return CGSize(width: 100.0, height: 100.0)
    }
    
    func reloadFamily() -> Void {
     
        if let family = rManager.realm.object(ofType: FamilyEntity.self, forPrimaryKey: getUser()?.familyActive) {
            let view = FamilyTitleView.instanceFromNib()
            view.bind(fam: family)
            self.navigationItem.titleView = view
        }
        
    }

}
extension  HomeCollectionViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = FamilyState
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            subcription in
            subcription.select { state in state.FamilyState }
        }
    }
    
    func newState(state: FamilyState) {
        reloadFamily()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        notificationToken?.invalidate()
    }
    
}
