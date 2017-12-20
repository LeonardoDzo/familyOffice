//
//  NotificationViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 20/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageViewX()
        imageView.image = #imageLiteral(resourceName: "background_no_notifications")
        self.collectionView.backgroundView = imageView
        imageView.contentMode = .scaleAspectFit
        imageView.filter = #colorLiteral(red: 0.9332545996, green: 0.9333854914, blue: 0.9332134128, alpha: 0.601654196)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NotificationViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
}
