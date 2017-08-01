//
//  AlbumViewController.swift
//  familyOffice
//
//  Created by Enrique Moya on 05/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Firebase
import DKImagePickerController
import Lightbox
import Foundation
import AVKit
import AVFoundation
import AudioToolbox


class AlbumViewController: UIViewController,UIGestureRecognizerDelegate, StoreSubscriber {
    
    @IBOutlet weak var collectionImages: UICollectionView!
    
    typealias StoreSubscriberStateType = GalleryState

    var currentAlbum: Album?
    var imgesAlbum = [ImageAlbum]()
    var selectedImage = -1
    var controller = LightboxController()
    var selectedItems = [String: GalleryImageCollectionViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Albums"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addImage))
        addButton.tintColor = #colorLiteral(red: 1, green: 0.2940415765, blue: 0.02801861018, alpha: 1)
        self.navigationItem.rightBarButtonItem = addButton
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        backButton.tintColor = #colorLiteral(red: 1, green: 0.2940415765, blue: 0.02801861018, alpha: 1)
        self.navigationItem.leftBarButtonItem = backButton
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 2, bottom: 10, right: 2)
        layout.itemSize = CGSize(width: (self.collectionImages.contentSize.width/4)-2, height: (self.collectionImages.contentSize.width/4)-2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionImages.collectionViewLayout = layout
        self.collectionImages.allowsMultipleSelection = true
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.collectionImages.addGestureRecognizer(lpgr)
    }
    func back() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addImage() {
        let picker = DKImagePickerController()
        picker.didSelectAssets = {(assets: [DKAsset]) in
            if assets.count > 0{
                for item in assets{
                    if item.isVideo{
                        let uid: String = NSUUID().uuidString + ".m4v"
                        let dir: String = NSTemporaryDirectory()
                        let urlIn = URL.init(fileURLWithPath: dir + uid, isDirectory: false, relativeTo: nil)
                        print(urlIn.absoluteString)
                        FileManager.default.createFile(atPath: urlIn.absoluteString, contents: nil, attributes: nil)
                        item.writeAVToFile(urlIn.absoluteString, presetName: AVAssetExportPresetMediumQuality, completeBlock: {flag in
                            if flag == true{
                                item.fetchAVAsset(.none, completeBlock: {(asset, hashing) in
                                    let generator = AVAssetImageGenerator(asset: asset!)
                                    generator.appliesPreferredTrackTransform = true
                                    let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
                                    var image: UIImage = UIImage()
                                    do{
                                        let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
                                        image = UIImage(cgImage: imageRef).resizeToMed()
                                        let data = try! Data(contentsOf: urlIn)
                                        let key = Constants.FirDatabase.REF.childByAutoId().key as String
                                        let imgAlbum: ImageAlbum = ImageAlbum(id: key, path: "", album: self.currentAlbum?.id, comments: [], reacts: [], uiimage: image,video: data)
                                        store.dispatch(InsertVideoAlbumAction(image: imgAlbum))
                                    }catch let error as NSError
                                    {
                                        self.view.makeToast("Error al subir video al album.", duration: 1.0, position: .center)
                                    }
                                })
                            }
                            })
                            /*
                                let asset = AVURLAsset(url: urlIn)
                                let generator = AVAssetImageGenerator(asset: item))
                                generator.appliesPreferredTrackTransform = true
                                let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
                                var image: UIImage = UIImage()
                            do{
                                let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
                                image = UIImage(cgImage: imageRef).resizeToMed()
                                let data = try! Data(contentsOf: urlIn)
                                let key = Constants.FirDatabase.REF.childByAutoId().key as String
                                let imgAlbum: ImageAlbum = ImageAlbum(id: key, path: "", album: self.currentAlbum?.id, comments: [], reacts: [], uiimage: image)
                                store.dispatch(InsertVideoAlbumAction(image: imgAlbum))
                            }catch let error as NSError
                            {
                                self.view.makeToast("Error al subir video al album.", duration: 1.0, position: .center)
                            }
                        })*/
                    }else{
                        item.fetchOriginalImageWithCompleteBlock({(image, data) in
                            if let img : UIImage = image{
                                if image is UIImage{
                                    //let imageData = self.resizeImage(image: image!, scale: CGFloat.init(20))
                                    let imageData = image?.resizeImage()
                                    let key = Constants.FirDatabase.REF.childByAutoId().key as String
                                    let imgAlbum: ImageAlbum = ImageAlbum(id: key, path: "", album: self.currentAlbum?.id, comments: [], reacts: [], uiimage: imageData!,video: nil)
                                    store.dispatch(InsertImagesAlbumAction(image: imgAlbum))
                                    self.imgesAlbum.append(ImageAlbum())
                                    self.collectionImages.reloadData()
                                }
                            }
                        })
                    }}
            }else{
                self.view.makeToast("No se agregaron imagenes.", duration: 1.0, position: .center)
            }
        }
        self.present(picker, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension AlbumViewController{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !(store.state.GalleryState.Album.id.isEmpty){
            store.subscribe(self){
                state in
                state.GalleryState
            }
            currentAlbum = store.state.GalleryState.Album
            self.navigationItem.title = currentAlbum?.title
            service.IMAGEALBUM_SERVICE.initObserves(ref: "", actions: [.value,.childRemoved])
        }else{
            _ = navigationController?.popViewController(animated: true)
        }
        self.collectionImages.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        store.unsubscribe(self)
        service.GALLERY_SERVICE.removeHandles()
    }
    func newState(state: GalleryState) {
        switch state.status {
        
        case .failed:
            self.collectionImages.reloadData()
            break
        case .finished:
            self.currentAlbum = store.state.GalleryState.Album
            self.imgesAlbum = (self.currentAlbum?.ObjImages)!
            self.collectionImages.reloadData()
            store.state.GalleryState.status = .none
            break
        case .Failed(let data):
            if data is ImageAlbum{
                self.collectionImages.reloadData()
                store.state.GalleryState.status = .none
            }
            if data is String{
                let msg: String = data as! String
                self.view.makeToast(msg, duration: 1.0, position: .center)
                store.state.FamilyState.status = .finished
            }
            if data is (Int,ImageAlbum){
                let value: (Int,ImageAlbum) = data as! (Int, ImageAlbum)
                let index = value.0 + 1
                self.view.makeToast("No se pudo eliminar la selección: \(index)", duration: 1.0, position: .bottom)
            }
            break
        case .Finished(let data):
            if data is ImageAlbum{
                store.state.GalleryState.status = .none
            }
            if data is (Int,ImageAlbum){
                let value: (Int,ImageAlbum) = data as! (Int, ImageAlbum)
                let index = value.0 + 1
                self.view.makeToast("Se elimino la selección: \(index)", duration: 1.0, position: .bottom)
                if self.selectedItems.count == 1{
                    self.cancelSelection()
                    store.state.GalleryState.status = .none
                }else{
                    let data: (Int,ImageAlbum) = data as! (Int,ImageAlbum)
                    self.selectedItems.removeValue(forKey: data.1.id)
                    self.navigationItem.title = "Seleccionados: \(self.selectedItems.count)"
                }
            }
            break
        case .none:
            break
        default:
            break
        }
    }
}
extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout,LightboxControllerPageDelegate,LightboxControllerDismissalDelegate{
    
    
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        self.viewWillAppear(true)
    }

    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        self.selectedImage = page
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print((currentAlbum?.ObjImages.count)!)
        return (currentAlbum?.ObjImages.count)!
    }
    
    func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state == UIGestureRecognizerState.began){
            let p = gestureRecognizer.location(in: self.collectionImages)
            if let indexPath: IndexPath = collectionImages.indexPathForItem(at: p){
                //do whatever you need to do
                let cell = self.collectionImages.cellForItem(at: indexPath) as! GalleryImageCollectionViewCell
                self.selectedItems[(cell.imageAlbum?.id)!] = cell
                self.collectionView(self.collectionImages, didSelectItemAt: indexPath)
                let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteImages))
                deleteButton.tintColor = #colorLiteral(red: 1, green: 0.2940415765, blue: 0.02801861018, alpha: 1)
                let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action:#selector(self.ShareData))
                share.tintColor = #colorLiteral(red: 1, green: 0.2940415765, blue: 0.02801861018, alpha: 1)
                let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelSelection))
                cancelButton.tintColor = #colorLiteral(red: 1, green: 0.2940415765, blue: 0.02801861018, alpha: 1)
                self.navigationItem.leftBarButtonItem = cancelButton
                self.navigationItem.rightBarButtonItems = [share, deleteButton]
            }
        }
        if (gestureRecognizer.state != UIGestureRecognizerState.ended){
            return
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagecell", for: indexPath) as! GalleryImageCollectionViewCell
        cell.playImage.image = #imageLiteral(resourceName: "play-button-32")
        cell.layer.borderWidth = 0
        cell.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        cell.imageBackground.backgroundColor = UIColor.clear
        cell.imageBackground.tintColor = UIColor.clear
        cell.imageBackground.alpha = 1
        let image = currentAlbum?.ObjImages[indexPath[1]]
        cell.bind(data: image!)
        cell.playImage.isHidden = false
        if image?.video == nil{
            currentAlbum?.ObjImages[indexPath[1]].uiimage = cell.imageBackground.image
            cell.playImage.isHidden = true
            return cell
        }
        currentAlbum?.ObjImages[indexPath[1]].uiimage = cell.imageBackground.image
        return cell
    }
    /*public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.fs_width/4, height: self.view.fs_width/4)
    }*/
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedItems.count > 0{
            let cell = self.collectionImages.cellForItem(at: indexPath) as! GalleryImageCollectionViewCell
            if self.selectedItems.keys.contains(where: {$0 == cell.imageAlbum?.id}){
                cell.playImage.image = #imageLiteral(resourceName: "success")
                cell.layer.borderWidth = 3.0
                cell.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
                cell.imageBackground.backgroundColor = UIColor.black
                cell.imageBackground.tintColor = UIColor.black
                cell.imageBackground.alpha = 0.20
                cell.playImage.isHidden = false
            }else{
                self.selectedItems[(cell.imageAlbum?.id)!] = cell
                cell.playImage.image = #imageLiteral(resourceName: "success")
                cell.layer.borderWidth = 3.0
                cell.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
                cell.imageBackground.backgroundColor = UIColor.black
                cell.imageBackground.tintColor = UIColor.black
                cell.imageBackground.alpha = 0.20
                cell.playImage.isHidden = false
            }
            self.navigationItem.title = "Seleccionados: \(self.selectedItems.count)"
        }else{
            var imagesGallery = [LightboxImage]()
            for item in (self.currentAlbum?.ObjImages)!{
                if item.video == nil{
                    imagesGallery.append(LightboxImage(imageURL: URL(string: item.path!)!, text: item.id, videoURL: nil))
                }else{
                    let cell = collectionView.cellForItem(at: indexPath) as! GalleryImageCollectionViewCell
                    imagesGallery.append(LightboxImage(image: cell.imageBackground.image!, text: item.id, videoURL: URL(string: item.path!)))
                }
            }
            // Create an instance of LightboxController.
            controller = LightboxController(images: imagesGallery, startIndex: indexPath[1])
            
            // Set delegates.
            controller.pageDelegate = self
            controller.dismissalDelegate = self
            
            // Config controller
            controller.dynamicBackground = false
            LightboxConfig.DeleteButton.enabled = true
            LightboxConfig.InfoLabel.enabled = false
            LightboxConfig.CloseButton.text = "Cerrar"
            LightboxConfig.DeleteButton.text = "Eliminar"
            LightboxConfig.loadImage = {
                imageView, URL, completion in
                // Custom image loading
                imageView.loadImage(urlString: URL.absoluteString)
                completion!(nil,imageView.image!)
            }
            controller.headerView.deleteButton.addTarget(self, action: #selector(deleteImage), for: .touchDown)
            
            // Present your controller.
            present(controller, animated: true, completion: nil)
        }
    }
    func cancelSelection(){
        self.selectedItems.removeAll()
        self.collectionImages.reloadData()
        self.navigationItem.title = "Albums"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addImage))
        addButton.tintColor = #colorLiteral(red: 1, green: 0.2940415765, blue: 0.02801861018, alpha: 1)
        self.navigationItem.rightBarButtonItems = []
        self.navigationItem.rightBarButtonItem = addButton
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        backButton.tintColor = #colorLiteral(red: 1, green: 0.2940415765, blue: 0.02801861018, alpha: 1)
        self.navigationItem.leftBarButtonItem = backButton

    }
    func ShareData(){
        var imageToShare = [Any]()
        for item in self.selectedItems{
            if item.value.imageAlbum?.video == nil{
                imageToShare.append(item.value.imageBackground.image!)
            }else{
                let video =  URL(string: (item.value.imageAlbum?.path)!)!
                imageToShare.append(video)
            }
        }
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // present the view controller
        self.present(activityViewController, animated: true, completion: {_ in
            self.cancelSelection()
        })
        
    }
    func deleteImage() {
        let key: String! = self.controller.images[self.controller.currentPage].text
        if let image = self.imgesAlbum.first(where: {$0.id == key}){
            let action = DeleteImagesGalleryAction.init(album: [image])
            store.dispatch(action)
        }
    }
    func deleteImages() {
        if self.selectedItems.count > 0 {
            let album = self.selectedItems.map({$0.value.imageAlbum!})
            let action = DeleteImagesGalleryAction.init(album: album)
            store.dispatch(action)
        }
    }
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = self.collectionImages.cellForItem(at: indexPath) as! GalleryImageCollectionViewCell
        if let data = self.selectedItems[(cell.imageAlbum?.id)!]{
            self.selectedItems.removeValue(forKey: (data.imageAlbum?.id)!)
            cell.layer.borderWidth = 0
            cell.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
            cell.imageBackground.backgroundColor = UIColor.clear
            cell.imageBackground.tintColor = UIColor.clear
            cell.imageBackground.alpha = 1
            if cell.imageAlbum?.video != nil{
                cell.playImage.image = #imageLiteral(resourceName: "play-button-32")
                cell.playImage.isHidden = false
            }else{
                cell.playImage.image = #imageLiteral(resourceName: "play-button-32")
                cell.playImage.isHidden = true
            }
            self.navigationItem.title = "Seleccionados: \(self.selectedItems.count)"
        }
        if self.selectedItems.count == 0 {
            self.navigationItem.title = "Albums"
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addImage))
            addButton.tintColor = #colorLiteral(red: 1, green: 0.2940415765, blue: 0.02801861018, alpha: 1)
            self.navigationItem.rightBarButtonItems = []
            self.navigationItem.rightBarButtonItem = addButton
            let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
            backButton.tintColor = #colorLiteral(red: 1, green: 0.2940415765, blue: 0.02801861018, alpha: 1)
            self.navigationItem.leftBarButtonItem = backButton
        }
    }

}



