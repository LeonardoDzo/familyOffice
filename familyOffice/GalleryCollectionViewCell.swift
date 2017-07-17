//
//  GalleryCollectionViewCell.swift
//  familyOffice
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell, AlbumBindable {
    
    var album: Album!
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var Total: UILabel!
    @IBOutlet weak var Image: UIImageView!
    override func layoutSubviews() {
        super.layoutSubviews()
        //self.Image.frame.size.width = self.bounds.size.width
        //self.Image.frame.size.height = self.bounds.size.height
        //self.Title.frame.size.width = self.bounds.size.width
    }
}
class GalleryImageCollectionViewCell: UICollectionViewCell, ImageAlbumBindable {
    
    @IBOutlet weak var imageBackground: UIImageView!
    
    var imageAlbum: ImageAlbum?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageBackground.frame.size.width = self.bounds.size.width
        self.imageBackground.frame.size.height = self.bounds.size.height
    }
}


class FamilyGalleryCollectionViewCell: UICollectionViewCell, FamilyBindable {
    
    var family: Family!
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var Image: UIImageView!
    override func layoutSubviews() {
        super.layoutSubviews()
        self.Image.frame.size.width = self.bounds.size.width
        self.Image.frame.size.height = self.bounds.size.height
        self.Title.frame.size.width = self.bounds.size.width
        //self.Image.loadImage(urlString: service.USER_SERVICE.users[0].photoURL)
    }
}
