//
//  ImageAlbumService.swift
//  familyOffice
//
//  Created by Enrique Moya on 10/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase
class ImageAlbumService: RequestService{
    func notExistSnapshot() {
        store.state.GalleryState.status = .failed
    }

    var handles: [(String, UInt, FIRDataEventType)] = []
    var Album: Album?
    
    private init(){}
    
    private static let instance : ImageAlbumService = ImageAlbumService()
    
    public static func Instance() -> ImageAlbumService {
        return instance
    }
    
    func initObserves(ref: String, actions: [FIRDataEventType]) -> Void {
        if(store.state.GalleryState.Album != nil){
            self.Album = store.state.GalleryState.Album
            for action in actions {
                if !handles.contains(where: { $0.0 == ref && $0.2 == action} ){
                    var handle = UInt()
                    handle = Constants.FirDatabase.REF.child("images").queryOrdered(byChild: "album").queryEqual(toValue: self.Album?.id!).observe(action, with: ({
                        ref in
                        self.addHandle(handle, ref: "images", action: action)
                        self.routing(snapshot: ref as! FIRDataSnapshot, action: action, ref: "images")
                    }))
                }
            }
        }
    }
    
    func addHandle(_ handle: UInt, ref: String, action: FIRDataEventType) {
        self.handles.append((ref,handle,action))
    }
    
    func inserted(ref: FIRDatabaseReference) {
        store.state.UserState.status = .finished
    }
    
    func routing(snapshot: FIRDataSnapshot, action: FIRDataEventType, ref: String) {
        switch action {
        case .childAdded:
            self.added(snapshot: snapshot)
            break
        case .childRemoved:
            self.removed(snapshot: snapshot)
            break
        case .value:
            self.add(snap: snapshot)
            break
        default:
            break
        }
    }
    
    func removeHandles() {
        for handle in self.handles {
            Constants.FirDatabase.REF.child(handle.0).removeObserver(withHandle: handle.1)
        }
        self.handles.removeAll()
    }
    
    func delete(_ ref: String, callback: @escaping ((Any) -> Void)) {
        Constants.FirDatabase.REF.child(ref).removeValue(completionBlock: {(error,snap) in
            if error != nil{
                callback(true)
            }else{
                callback(false)
            }
        })
    }
    func add(snap: FIRDataSnapshot) {
        for item in snap.children{
            self.added(snapshot: item as! FIRDataSnapshot)
        }
        store.state.GalleryState.status = .finished
    }
    func added(snapshot: FIRDataSnapshot) {
        let image = ImageAlbum(snap: snapshot)
        if !store.state.GalleryState.Album.ObjImages.contains(where: {$0.id == image.id}){
            store.state.GalleryState.Album.ObjImages.append(image)
            let array = store.state.GalleryState.Gallery[service.GALLERY_SERVICE.refUserFamily!]?.index(where: {$0.id == image.album})
            store.state.GalleryState.Gallery[service.GALLERY_SERVICE.refUserFamily!]?[array!] = store.state.GalleryState.Album
        }
    }
    func removed(snapshot: FIRDataSnapshot) {
        let image = ImageAlbum(snap: snapshot)
        if store.state.GalleryState.Album.ObjImages.contains(where: {$0.id == image.id}){
            let index = store.state.GalleryState.Album.ObjImages.index(where: {$0.id == image.id})
            store.state.GalleryState.Album.ObjImages.remove(at: index!)
            let array = store.state.GalleryState.Gallery[service.GALLERY_SERVICE.refUserFamily!]?.index(where: {$0.id == image.album})
            store.state.GalleryState.Gallery[service.GALLERY_SERVICE.refUserFamily!]?[array!] = store.state.GalleryState.Album
            Constants.FirDatabase.REF.child("album/\(service.GALLERY_SERVICE.refUserFamily!)/\(image.album!)/images/\(image.id!)").removeValue()
            Constants.FirStorage.STORAGEREF.child("images/\(image.id!).jpg").delete(completion: {error in
                if error != nil{
                    store.state.GalleryState.status = .Failed("Error al borrar archivo de almacenamiento remoto, contacte al soporte.")
                }
            })
            store.state.GalleryState.status = .finished
        }
    }
    
    
    // ninja-method to upload files
    func InsertImage(image: ImageAlbum) {
        var image: ImageAlbum! = image
        let reference: String = "images/\(image.id!)"
        service.STORAGE_SERVICE.insert("\(reference)\(".jpg")", value: image.uiimage, callback: {metadata in
            if let metadata: FIRStorageMetadata = metadata as? FIRStorageMetadata{
                image.path = metadata.downloadURL()?.absoluteString
                service.IMAGEALBUM_SERVICE.insert(reference, value: image.toDictionary(), callback: {ref in
                    if ref is FIRDatabaseReference{
                        let path: String! = "album/\(service.GALLERY_SERVICE.refUserFamily!)/\(image.album!)/images"
                        service.GALLERY_SERVICE.update(path!, value: [image.id as AnyHashable : true], callback: {response in
                            if response is FIRDatabaseReference{
                                store.state.GalleryState.status = .Finished(image)
                            }
                        })
                    }else{
                        store.state.GalleryState.status = .Failed(image)
                    }
                })
            }else{
                store.state.GalleryState.status = .Failed(image)
            }
        })
    }
}
