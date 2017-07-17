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

class AlbumViewController: UIViewController, StoreSubscriber {
    
    @IBOutlet weak var collectionImages: UICollectionView!
    
    typealias StoreSubscriberStateType = GalleryState

    var currentAlbum: Album?
    var imgesAlbum = [ImageAlbum]()
    var selectedImage = -1
    var controller = LightboxController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Albums"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addImage))
        self.navigationItem.rightBarButtonItem = addButton
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 2, bottom: 10, right: 2)
        layout.itemSize = CGSize(width: (self.collectionImages.contentSize.width/4)-2, height: (self.collectionImages.contentSize.width/4)-2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionImages.collectionViewLayout = layout

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
                for (index,item) in assets.enumerated(){
                    if item.isVideo{
                        
                    }else{
                        item.fetchOriginalImageWithCompleteBlock({(image, data) in
                            if let img : UIImage = image{
                                if image is UIImage{
                                    let imageData = self.resizeImage(image: image!, scale: CGFloat.init(20))
                                    let key = Constants.FirDatabase.REF.childByAutoId().key as String
                                    let imgAlbum: ImageAlbum = ImageAlbum(id: key, path: "", album: self.currentAlbum?.id, comments: [], reacts: [], uiimage: imageData)
                                    store.dispatch(InsertImagesAlbumAction(image: imgAlbum))
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
    func resizeImage(image: UIImage, scale: CGFloat) -> UIImage {
        if !(image.size.width * image.scale).isLess(than: CGFloat.init(600)) || !(image.size.height * image.scale).isLess(than: CGFloat.init(600)) {
            let newWidth = image.size.width * (scale/100)
            let newHeight = image.size.height * (scale/100)
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }else{
            return image
        }
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
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        store.unsubscribe(self)
        service.GALLERY_SERVICE.removeHandles()
    }
    func newState(state: GalleryState) {
        switch state.status {
        case .failed:
            break
        case .finished:
            self.currentAlbum = store.state.GalleryState.Album
            self.imgesAlbum = (self.currentAlbum?.ObjImages)!
            
            store.state.GalleryState.status = .none
            break
        case .Failed(let data):
            if data is ImageAlbum{
                let image: ImageAlbum = data as! ImageAlbum
                print(image.id)
                store.state.GalleryState.status = .none
            }
            if data is String{
                let msg: String = data as! String
                self.view.makeToast(msg, duration: 1.0, position: .center)
                store.state.FamilyState.status = .finished
            }
            break
        case .Finished(let data):
            if let image: ImageAlbum = data as! ImageAlbum{
                store.state.GalleryState.status = .none
            }
            break
        case .none:
            break
        default:
            break
        }
        self.collectionImages.reloadData()
    }
}
extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,LightboxControllerPageDelegate,LightboxControllerDismissalDelegate{
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        print("dismis")
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
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagecell", for: indexPath) as! GalleryImageCollectionViewCell
            let image = currentAlbum?.ObjImages[indexPath[1]]
            cell.bind(data: image!)
        currentAlbum?.ObjImages[indexPath[1]].uiimage = cell.imageBackground.image
            return cell
    }
    /*public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.fs_width/4, height: self.view.fs_width/4)
    }*/
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var imagesGallery = [LightboxImage]()
        for item in (self.currentAlbum?.ObjImages)!{
            imagesGallery.append(LightboxImage(imageURL: URL(string: item.path!)!, text: item.id, videoURL: nil))
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
        controller.headerView.deleteButton.addTarget(self, action: #selector(deleteImage), for: .touchDown)
        
        // Present your controller.
        present(controller, animated: true, completion: nil)
    }
    func deleteImage() {
        print("delete",self.controller.currentPage,self.controller.images[self.controller.currentPage].text)
        let key: String! = self.controller.images[self.controller.currentPage].text
        service.IMAGEALBUM_SERVICE.delete("images/\(key!)", callback: {response in
            if let resp: Bool = response as! Bool{
                if resp == true{
                    self.controller.dismiss(animated: true, completion: nil)
                    self.view.makeToast("Error al eliminar archivo.", duration: 1.0, position: .center)
                }
            }else{
                self.controller.dismiss(animated: true, completion: nil)
                self.view.makeToast("Error al eliminar archivo.", duration: 1.0, position: .center)
            }
        })
    }
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }

}



