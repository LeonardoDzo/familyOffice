//
// Created by Enrique Moya on 27/06/17.
// Copyright (c) 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
struct ImageAlbum {


    static let kId = "Id"
    static let kPath = "path"
    static let kComments = "comments"
    static let kReacts = "reacts"
    static let kAlbum = "album"
    static let kVideo = "video"


    var id: String!
    var path: String!
    var comments: [String] = []
    var reacts: [String] = []
    var album: String!
    var uiimage: UIImage?
    var video: String?
    var DataVideo: Data?

    init(){
        self.id = ""
        self.path = ""
        self.comments = []
        self.reacts = []
        self.album = ""
        self.uiimage = nil
        self.video = nil
    }
    init(id: String!,path: String!,album: String!,comments: [String],reacts: [String],uiimage: UIImage, video: Data?){
        self.id = id
        self.path = path
        self.comments = comments
        self.reacts = reacts
        self.album = album
        self.uiimage = uiimage
        self.video = ""
        self.DataVideo = video
    }
    init(snap: DataSnapshot){
        self.id = snap.key
        let snapValue = snap.value as! NSDictionary
        self.path = service.UTILITY_SERVICE.exist(field: ImageAlbum.kPath, dictionary: snapValue)
        self.comments = service.UTILITY_SERVICE.exist(field: ImageAlbum.kComments, dictionary: snapValue)
        self.reacts = service.UTILITY_SERVICE.exist(field: ImageAlbum.kReacts, dictionary: snapValue)
        self.album = service.UTILITY_SERVICE.exist(field: ImageAlbum.kAlbum, dictionary: snapValue)
        self.video = service.UTILITY_SERVICE.exist(field: ImageAlbum.kVideo, dictionary: snapValue) == "" ? nil : service.UTILITY_SERVICE.exist(field: ImageAlbum.kVideo, dictionary: snapValue)
    }
    func toDictionary() -> NSDictionary {
        return [
            ImageAlbum.kPath: self.path,
            ImageAlbum.kComments: self.comments,
            ImageAlbum.kReacts: self.reacts,
            ImageAlbum.kAlbum: self.album,
            ImageAlbum.kVideo: self.video!
        ]
    }
}
protocol ImageAlbumBindable: AnyObject {
    var imageAlbum: ImageAlbum? {get set}
    var imageBackground: CustomUIImageView! {get}
}
extension ImageAlbumBindable{
    var imageBackground: CustomUIImageView!{
        return nil
    }
    func bind(data: ImageAlbum){
        self.imageAlbum = data
        bind()
    }
    func bind() {
        guard let imageAlbum = self.imageAlbum else{
            return
        }
        if let imageBackground = self.imageBackground{
            if imageAlbum.video != nil{
                if(!(imageAlbum.video?.isEmpty)!){
                    imageBackground.loadImage(urlString: imageAlbum.video!)
                }
                else{
                    imageBackground.image = #imageLiteral(resourceName: "notfound")
                }
            }else{
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
}
