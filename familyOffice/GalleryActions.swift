//
//  GalleryActions.swift
//  familyOffice
//
//  Created by Enrique Moya on 06/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import Foundation
import ReSwift
import ReSwiftRecorder
let galleryActionTypeMap: TypeMap = [
    InsertGalleryAction.type: InsertGalleryAction.self,
    DeleteGalleryAction.type: DeleteGalleryAction.self,
    InsertImagesAlbumAction.type: InsertImagesAlbumAction.self,
    InsertVideoAlbumAction.type: InsertVideoAlbumAction.self,
    DeleteImagesGalleryAction.type: DeleteImagesGalleryAction.self
]

struct InsertGalleryAction: StandardActionConvertible {
    static let type = "GALLERY_ACTION_INSERT"
    var album: NSDictionary!
    init(album: NSDictionary) {
        self.album = album
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertGalleryAction.type, payload: [:],isTypedAction: true)
    }
}
struct DeleteGalleryAction: StandardActionConvertible {
    static let type = "GALLERY_ACTION_DELETE"
    var album: Album!
    
    init(album: Album) {
        self.album = album
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: DeleteGalleryAction.type, payload: [:], isTypedAction: true)
    }
}
struct DeleteImagesGalleryAction: StandardActionConvertible {
    static let type = "GALLERYIMAGE_ACTION_DELETE"
    var images: [ImageAlbum]!
    
    init(album: [ImageAlbum]) {
        self.images = album
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: DeleteImagesGalleryAction.type, payload: [:], isTypedAction: true)
    }
}
struct GetGalleyAction: Action {
}

struct InsertImagesAlbumAction: StandardActionConvertible {
        static let type = "GALLERYIMAGE_ACTION_INSERT"
    var image: ImageAlbum!
    init(image: ImageAlbum){
        self.image = image
    }


    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertImagesAlbumAction.type, payload: [:], isTypedAction: true)
    }

}
struct InsertVideoAlbumAction: StandardActionConvertible {
    static let type = "GALLERYVIDEO_ACTION_INSERT"
    var image: ImageAlbum!
    init(image: ImageAlbum){
        self.image = image
    }
    
    
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: InsertVideoAlbumAction.type, payload: [:], isTypedAction: true)
    }
    
}
