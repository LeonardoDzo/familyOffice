//
// Created by Enrique Moya on 27/06/17.
// Copyright (c) 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDatabaseReference
import FirebaseDatabase.FIRDatabaseQuery
import FirebaseStorage.FIRStorage
import FirebaseStorage.FIRStorageMetadata

public class GalleryService : RequestService {
    func notExistSnapshot() {
        store.state.GalleryState.status = .failed
    }
    
    var handles: [(String, UInt, DataEventType)] = []

    var albums: [Album] = []
    var saveAlbums: [String:[Album]] = [:]
    var activeAlbum: String!
    var refUserFamily: String!

    private init() {}

    static private let instance = GalleryService()

    public static func Instance() -> GalleryService {
        return instance
    }

    func initObserves(ref: String, actions: [DataEventType]) -> Void {
        store.state.GalleryState.status = .loading
        for action in actions {
            self.child_action(ref: ref, action: action)
        }
    }
    func routing(snapshot: DataSnapshot, action: DataEventType, ref: String) {
        if(ref.components(separatedBy: "/")[0] == "images"){
            imageActions(snapshot: snapshot, action: action, ref: ref)
            return
        }
        switch action {
        case .childAdded:
            self.added(snapshot: snapshot)
            break
        case .childRemoved:
            self.removed(snapshot: snapshot)
            break
        case .childChanged:
            self.updated(snapshot: snapshot, id: snapshot.key)
            break
        case .value:
            self.add(value: snapshot)
            break
        default:
            break
        }
    }
    func imageActions (snapshot: DataSnapshot, action: DataEventType,ref: String)-> Void{
        switch action {
        case .childAdded:
            service.IMAGEALBUM_SERVICE.valueSingleton(ref: ref)
            break
        case.childRemoved:
            service.IMAGEALBUM_SERVICE.valueSingleton(ref: ref)
            break
        default:
            break
        }
    }
    func addHandle(_ handle: UInt, ref: String, action: DataEventType) {
        self.handles.append((ref,handle,action))
    }

    func removeHandles() {
        for handle in handles {
            Constants.FirDatabase.REF.child(handle.0).removeAllObservers()
        }
        self.handles.removeAll()
    }

    func inserted(ref: DatabaseReference) {
    }
    func delete(_ ref: String, callback: @escaping ((Any) -> Void)) {
    }
    func notExistSnapshot(ref: String) {
        
    }
}
extension GalleryService: repository {
    func added(snapshot: FirebaseDatabase.DataSnapshot) {
        let id = snapshot.ref.description().components(separatedBy: "/")[4].decodeUrl()
        let album = Album(snapshot: snapshot)
        
        if(store.state.GalleryState.Gallery[id] == nil){
            store.state.GalleryState.Gallery[id] = []
        }
        
        if !(store.state.GalleryState.Gallery[id]?.contains(where: {$0.id == album.id}))!{
            store.state.GalleryState.Gallery[id]?.append(album)
        }
    }

    func add(value: DataSnapshot) -> Void {
        store.state.GalleryState.Gallery.removeAll()
        for item in value.children{
            self.added(snapshot: item as! DataSnapshot)
        }
        store.state.GalleryState.status = .finished
    }
    func updated(snapshot: FirebaseDatabase.DataSnapshot, id: Any) {
    }

    func removed(snapshot: FirebaseDatabase.DataSnapshot) {
        if let index = albums.index(where: {$0.id == snapshot.key}){
            self.albums.remove(at: index)
            
        }
    }
    func createAlbum(data: NSDictionary,callback: @escaping (String)-> Void){
        var album = data.value(forKey: "album") as! Album
        if !(data.value(forKey: "file") is NSNull) {
            service.STORAGE_SERVICE.insert(data.value(forKey: "reference-img") as! String, value: data.value(forKey: "file") as Any, callback: { metadata in
                if let meta = metadata as? StorageMetadata{
                    album.cover = (meta.downloadURL()?.absoluteString)!
                    service.GALLERY_SERVICE.insert(data.value(forKey: "reference") as! String, value: album.toDictionary(), callback: {reference in
                        if let ref = reference as? DatabaseReference{
                            ref.observeSingleEvent(of: .value, with: {snapshot in
                                callback("Guardado correctamente")
                            })
                        }else{
                            callback("Error")
                        }
                    })
                }else{
                    callback("Error")
                }
            })
        }else{
            service.GALLERY_SERVICE.insert(data.value(forKey: "reference") as! String, value: album.toDictionary(), callback: {reference in
                if let ref = reference as? DatabaseReference{
                    ref.observeSingleEvent(of: .value, with: {snapshot in
                        _ = Album(snapshot: snapshot)
                        callback("Guardado sin portada")
                    })
                }else{
                    callback("Error")
                }
            })
        }
    }
}
