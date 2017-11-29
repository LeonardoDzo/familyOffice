//
//  chatCollectionViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 21/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

private let chatIndentifier = "CellChat"
private let groupIndentifier = "CellGroup"
private let memberIndentifier = "CellMember"

class chatCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HandleMenuBar {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        setupMenuBar()
        setupCollectionView()
        style_1()
        let logOutButton = UIBarButtonItem(title: "Nuevo", style: .plain, target: self, action:nil)
        navigationItem.rightBarButtonItems = [logOutButton]
        

        // Do any additional setup after loading the view.
    }
    func handleBack()  {
        _ = self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func setupCollectionView() {
        if let flowlayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowlayout.scrollDirection = .horizontal
            flowlayout.minimumLineSpacing = 0
        }
        collectionView?.backgroundColor = UIColor.white
        self.collectionView!.register(ChatTableViewController.self, forCellWithReuseIdentifier: chatIndentifier)
        self.collectionView!.register(GroupTableViewCell.self, forCellWithReuseIdentifier: groupIndentifier)
      //  self.collectionView!.register(MemberTableViewCell.self, forCellWithReuseIdentifier: memberIndentifier)
        self.collectionView!.contentInset = UIEdgeInsets(top: 150, left: 0, bottom: 0, right: 0)
        self.collectionView!.scrollIndicatorInsets = UIEdgeInsets(top: 150, left: 0, bottom: 0, right: 0)
        
        collectionView?.isPagingEnabled = true
    }
    
    let menuBar: MenuBar = {
        let mb = MenuBar()
        mb.array = ["CHAT","GRUPOS","MIEMBROS"]
        mb.setupHorizontalBar()
        return mb
    }()
    private func setupMenuBar() {
        
        self.view.addSubview(menuBar)
        self.view.addContraintWithFormat(format: "H:|[v0]|", views: menuBar)
        self.view.addContraintWithFormat(format: "V:|[v0(50)]|", views: menuBar)
        menuBar.handleMapSearchDelegate = self
        menuBar.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatIndentifier, for: indexPath) as! ChatTableViewController
           
            return cell
        }else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupIndentifier, for: indexPath) as! GroupTableViewCell
         
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupIndentifier, for: indexPath) as! GroupTableViewCell
       
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftAnchorContraint?.constant = scrollView.contentOffset.x / CGFloat(menuBar.array.count)
    }
    
    func scrollMenuIndex(_ menuIndex: Int) -> Void {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = true
        
    }


}
