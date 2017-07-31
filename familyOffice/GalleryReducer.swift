//
//  GalleryReducer.swift
//  familyOffice
//
//  Created by Enrique Moya on 06/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
struct GalleryReducer: Reducer {
    func handleAction(action: Action, state: GalleryState?) -> GalleryState {
        var stateAux = state ?? GalleryState(Gallery: [:], Album: Album(), status: .none)
        switch action {
        case let action as InsertGalleryAction:
            if action.album != nil {
            insert(album: action.album)
            stateAux.status = .loading
                return stateAux
            }
            break
        case let action as InsertImagesAlbumAction:
            if action.image != nil {
                addImage(image: action.image)
                stateAux.status = .none
                return stateAux
            }
            break
        case let action as InsertVideoAlbumAction:
            if action.image != nil{
                addVideo(image: action.image)
                stateAux.status = .none
                return stateAux
            }
            break
        case let action as DeleteImagesGalleryAction:
            if action.images != nil{
                deleteImages(images: action.images)
                stateAux.status = .loading
                return stateAux
            }
            break
        default:
            break
        }
        return stateAux
    }
    func deleteImages(images: [ImageAlbum]){
        for (index,item) in images.enumerated(){
            let key: String! = item.id!
            service.IMAGEALBUM_SERVICE.delete("images/\(key!)", callback: {response in
                if let resp: Bool = response as? Bool{
                    if resp == true{
                        store.state.GalleryState.status = .Finished((index,item))
                    }else{
                        store.state.GalleryState.status = .Failed((index,item))
                    }
                }else{
                    store.state.GalleryState.status = .Failed((index,item))
                }
            })
        }
        return
    }
    func addImage(image: ImageAlbum) {
        service.IMAGEALBUM_SERVICE.InsertImage(image: image)
        return
    }
    func addVideo(image: ImageAlbum) {
        service.IMAGEALBUM_SERVICE.InsertVideo(image: image)
        return
    }
    func insert(album: NSDictionary){
        service.GALLERY_SERVICE.createAlbum(data: album, callback: {errors in
            if errors == "Guardado sin portada" || errors == "Guardado correctamente"{
                let data = album["album"] as! Album
                let id = (album["reference"] as! String).components(separatedBy: "/")[1]
                store.state.GalleryState.Gallery[id]?.append(data)
                store.state.GalleryState.status = .Finished(errors)
            }else{
                store.state.GalleryState.status = .failed
            }
        })
    }
}
