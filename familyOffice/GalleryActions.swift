//
//  GalleryActions.swift
//  familyOffice
//
//  Created by Enrique Moya on 06/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import Foundation
import ReSwift


struct InsertGalleryAction: Action {
    var album: NSDictionary!
    init(album: NSDictionary) {
        self.album = album
    }

}
struct DeleteGalleryAction: Action {
    var album: Album!
    
    init(album: Album) {
        self.album = album
    }
}
struct DeleteImagesGalleryAction: Action {
    var images: [ImageAlbum]!
    
    init(album: [ImageAlbum]) {
        self.images = album
    }
}
struct GetGalleyAction: Action {
}

struct InsertImagesAlbumAction: Action {
    var image: ImageAlbum!
    init(image: ImageAlbum){
        self.image = image
    }


}
struct InsertVideoAlbumAction: Action {
    var image: ImageAlbum!
    init(image: ImageAlbum){
        self.image = image
    }
}
