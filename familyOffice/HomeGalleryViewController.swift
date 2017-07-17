//
//  HomeGalleryViewController.swift
//  familyOffice
//
//  Created by mac on 23/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Firebase
class HomeGalleryViewController: UIViewController, UITabBarDelegate, HandleFamilySelected {
    var personal:[Album] = []

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectionSegmentcontrol: UISegmentedControl!
    var familiar:[Family] = []
    
    let settingLauncher = SettingLauncher()
    func handleMore(_ sender: Any) {
        settingLauncher.showSetting()
        settingLauncher.handleFamily = self

    }

    
    var key: String! = store.state.UserState.user?.id ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_more_button"), style: .plain, target: self, action:  #selector(self.handleMore(_:)))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.AddAlbum))
        self.navigationItem.rightBarButtonItems = [moreButton,addButton]
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = "Albums"
        self.tabBar.delegate = self
        // Do any additional setup after loading the view.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.headerReferenceSize.height = 0
        layout.itemSize = CGSize(width: (self.collectionView.frame.size.width), height: (self.collectionView.frame.size.height / 3)-2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = layout
    }
    func back() -> Void {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func changeSelection(_ sender: UISegmentedControl) {
        self.ChangeSelected()
    }
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.ChangeSelected()
    }
    func ChangeSelected() {
        if(tabBar.selectedItem?.tag == 0){
            self.navigationItem.title = "Albums"
            self.key = store.state.UserState.user?.id ?? ""
            service.GALLERY_SERVICE.refUserFamily = self.key
            self.InitObserver()
        }else{
            self.key = store.state.UserState.user?.familyActive ?? ""
            if let family: Family = store.state.FamilyState.families.first(where: {$0.id == self.key}) {
                self.navigationItem.title = "Familia: \(family.name!)"
                service.GALLERY_SERVICE.refUserFamily = self.key
                self.InitObserver()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func AddAlbum() {
        store.state.GalleryState.status = .none
        self.performSegue(withIdentifier: "AddAlbumSegue", sender: nil)
    }

}
extension HomeGalleryViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return personal.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GalleryCollectionViewCell
        let album = personal[indexPath.item]
        cell.bind(album: album)
        return cell
    }
    /*public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 130)
    }*/

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let keyAlbum = self.personal[indexPath[1]].id
        service.GALLERY_SERVICE.activeAlbum = keyAlbum
        store.state.GalleryState.Album = self.personal[indexPath[1]]
        service.GALLERY_SERVICE.initObserves(ref: "images/\(keyAlbum)", actions: [.childAdded])
        service.GALLERY_SERVICE.refUserFamily = self.key
        self.performSegue(withIdentifier: "AlbumDetailSegue", sender: nil)
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        collectionView.reloadItems(at: [indexPath])
    }


}

extension HomeGalleryViewController: StoreSubscriber{
    typealias StoreSubscriberStateType = GalleryState
    
    func selectFamily() {
       self.ChangeSelected()
        collectionView.reloadData()
    }
    func InitObserver() {
        service.GALLERY_SERVICE.initObserves(ref: "album/\(key!)", actions: [.value])
    }

    override func viewWillAppear(_ animated: Bool) {
        self.InitObserver()
        store.subscribe(self){
            state in
            state.GalleryState
        }
    }
    func newState(state: GalleryState) {
        switch state.status {
        case .failed:
            self.view.hideToastActivity()
            personal = []
            store.state.GalleryState.status = .none
            self.view.makeToast("No hay albums.", duration: 1.0, position: .center)
            break
        case .none:
            self.view.hideToastActivity()
            self.key = store.state.UserState.user?.familyActive ?? ""
            if let family: Family = store.state.FamilyState.families.first(where: {$0.id == self.key}) {
                self.navigationItem.title = "Familia: \(family.name!)"
                service.GALLERY_SERVICE.refUserFamily = self.key
            }
            break
        case .finished:
            self.view.hideToastActivity()
            personal = store.state.GalleryState.Gallery[key!] ?? []
            self.collectionView?.reloadData()
            service.GALLERY_SERVICE.initObserves(ref: "album/\(key!)", actions: [.childAdded])
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        default:
            self.view.hideToastActivity()
            break
        }
        collectionView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        store.unsubscribe(self)
        service.GALLERY_SERVICE.removeHandles()
    }
}
