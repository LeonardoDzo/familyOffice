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


class homesBtn {
    var image: UIImage!
    var color: UIColor!
    var segue = ""
    init(_ img: UIImage, _ color: UIColor, _ segue: String) {
        self.image = img
        self.color = color
        self.segue = segue
    }
}

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var btnsArray = [homesBtn(#imageLiteral(resourceName: "Calendar"), #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),"calendarSegue"), homesBtn(#imageLiteral(resourceName: "chat"), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), "chatSegue"), homesBtn(#imageLiteral(resourceName: "safeBox"), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), "safeBoxSegue"), homesBtn(#imageLiteral(resourceName: "insurance"),#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),""), homesBtn(#imageLiteral(resourceName: "FirstKit"), #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1),"firstAidKitSegue")]
    lazy var settingLauncher : SettingLauncher = {
        let launcher = SettingLauncher()
        return launcher
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let changeFam = UIBarButtonItem(image: #imageLiteral(resourceName: "changeFam"), style: .plain, target: self, action: #selector(self.changefam))
        self.navigationItem.rightBarButtonItem = changeFam
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.tag = indexPath.row
        cell.icon.image = btn.image
        cell.icon.backgroundColor = btn.color
        
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let btn = btnsArray[indexPath.row]
        self.performSegue(withIdentifier: btn.segue, sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == btnsArray.count-1 {
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
    }
    
}
