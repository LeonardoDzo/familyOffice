//
// Created by Enrique Moya on 27/06/17.
// Copyright (c) 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
struct ImageAlbum {

    //Ninja Statics

    static let kId = "Id"
    static let kPath = "path"
    static let kComments = "comments"
    static let kReacts = "reacts"
    static let kAlbum = "album"

    //Samurai Variables

    var id: String!
    var path: String!
    var comments: [String] = []
    var reacts: [String] = []
    var album: String!
    var uiimage: UIImage?

    init(){
        self.id = ""
        self.path = ""
        self.comments = []
        self.reacts = []
        self.album = ""
        self.uiimage = nil
    }
    init(id: String!,path: String!,album: String!,comments: [String],reacts: [String],uiimage: UIImage){
        self.id = id
        self.path = path
        self.comments = comments
        self.reacts = reacts
        self.album = album
        self.uiimage = uiimage
    }
    init(snap: FIRDataSnapshot){
        self.id = snap.key
        let snapValue = snap.value as! NSDictionary
        self.path = service.UTILITY_SERVICE.exist(field: ImageAlbum.kPath, dictionary: snapValue)
        self.comments = service.UTILITY_SERVICE.exist(field: ImageAlbum.kComments, dictionary: snapValue)
        self.reacts = service.UTILITY_SERVICE.exist(field: ImageAlbum.kReacts, dictionary: snapValue)
        self.album = service.UTILITY_SERVICE.exist(field: ImageAlbum.kAlbum, dictionary: snapValue)
    }
    func toDictionary() -> NSDictionary {
        return [
            ImageAlbum.kPath: self.path,
            ImageAlbum.kComments: self.comments,
            ImageAlbum.kReacts: self.reacts,
            ImageAlbum.kAlbum: self.album
        ]
    }
}
protocol ImageAlbumBindable: AnyObject {
    var imageAlbum: ImageAlbum? {get set}
    var imageBackground: UIKit.UIImageView! {get}
}
extension ImageAlbumBindable{
    var imageBackground: UIKit.UIImageView!{
        return nil
    }
    //Bind Ninja
    func bind(data: ImageAlbum){
        self.imageAlbum = data
        bind()
    }
    func bind() {
        guard let imageAlbum = self.imageAlbum else{
            return
        }
        if let imageBackground = self.imageBackground{
            if imageAlbum.path != nil{
                if(!imageAlbum.path.isEmpty){
                    imageBackground.loadImage(urlString: imageAlbum.path)
                }
                else{
                    imageBackground.image = #imageLiteral(resourceName: "notfound")
                }
            }
        }
    }
}
