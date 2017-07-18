//
//  AlbumModel.swift
//  familyOffice
//
//  Created by mac on 26/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseDatabase.FIRDatabaseReference

struct Album {
    static let kId = "Id"
    static let kCover = "cover"
    static let kTitle = "title"
    static let kImage = "images"

    var id: String!
    var cover: String!
    var title: String!
    var images = [String]()
    var ObjImages: [ImageAlbum] = []

    init(){
        self.id = ""
        self.cover = ""
        self.title = ""
        self.images = []
    }
    init(id: String,cover: String = "",title: String,images: [String]){
        self.id = id
        self.cover = cover
        self.title = title
        self.images = images
    }
    init(snapshot: FirebaseDatabase.FIRDataSnapshot){
        self.id = snapshot.key
        let snapValue = snapshot.value as! NSDictionary
        self.cover = service.UTILITY_SERVICE.exist(field: Album.kCover, dictionary: snapValue)
        self.title = service.UTILITY_SERVICE.exist(field: Album.kTitle, dictionary: snapValue)
        self.images = service.UTILITY_SERVICE.exist(field: Album.kImage, dictionary: snapValue)
        
    }
    mutating
    func toDictionary() -> NSDictionary {
        return [
                Album.kTitle: self.title,
                Album.kImage: self.images,
                Album.kCover: self.cover
        ]
    }
}
protocol AlbumBindable: AnyObject {
    var album: Album! {get set}
    var Title: UIKit.UILabel! {get}
    var Total: UIKit.UILabel! {get}
    var Image: UIKit.UIImageView! {get}
}
extension AlbumBindable{
    var Title: UIKit.UILabel!{
        return nil
    }
    var Total: UIKit.UILabel!{
        return nil
    }
    var Image: UIKit.UIImageView!{
        return nil
    }
    //Bind Ninja
    func bind(album: Album){
        self.album = album
        bind()
    }
    func bind() {
        guard let album = self.album else{
            return
        }
        if let titleLabel = self.Title{
            if album.title != nil{
                titleLabel.text = (album.title?.isEmpty)! ? "Sin título" : "\(album.title!)"
            }else{
                titleLabel.text = "Sin título"
            }
        }
        if let totalLabel = self.Total{
            if album.images.count > 0{
                totalLabel.text = "(\(album.images.count)) fotos"
            }else{
                totalLabel.text = "(0) fotos"
            }
        }
        if let imageBackground = self.Image{
            if album.cover != nil{
                if(!album.cover.isEmpty){
                    imageBackground.loadImage(urlString: album.cover)
                }else{
                    imageBackground.image = #imageLiteral(resourceName: "album_default")
                }
            }
        }
    }
}

