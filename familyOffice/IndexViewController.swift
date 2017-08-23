//
//  IndexViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import MobileCoreServices
import ReSwift
import Firebase
import Lightbox
import Photos

class IndexViewController: UIViewController, UICollectionViewDataSource,UINavigationControllerDelegate, UICollectionViewDelegate,UIDocumentMenuDelegate,UIDocumentPickerDelegate,LightboxControllerPageDelegate,LightboxControllerDismissalDelegate  {
    
    var flag = false
    var files:[SafeBoxFile] = []
    var userId = store.state.UserState.user?.id
    var player:AVPlayer!
    
    var lightboxController = LightboxController()
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var filesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barButton = UIBarButtonItem(title: "Atras", style: .plain, target: self, action: #selector(self.handleBack))
        self.navigationItem.leftBarButtonItem = barButton
        // Do any additional setup after loading the view.
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.3137395978, green: 0.1694342792, blue: 0.5204931498, alpha: 1)]
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleNew))
        addButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        backButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        self.navigationItem.rightBarButtonItems = [addButton]
    }
    
    func updateFlag() {
        flag  = false
        verify()
    }
    
    func verify() -> Void {
        if !flag {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func back() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func handleNew() -> Void {
        
        let alert = UIAlertController(title: "Subir archivo", message: "¿De dónde desea seleccionar el archivo?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cámara", style: .default , handler: { (action) in
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Galería", style: .default , handler: { (action) in
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Importar", style: .default, handler: { (action) in
            let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF), String(kUTTypeData)], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
            
        alert.modalPresentationStyle = UIModalPresentationStyle.currentContext
        
        present(alert, animated: true) {
        }
        
    }

   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func handleBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fileID", for: indexPath) as! FileCollectionViewCell
        
        cell.fileNameLabel.text = self.files[indexPath.row].filename
        let ext:NSString = self.files[indexPath.row].filename! as NSString
        
        switch ext.pathExtension {
        case "png":
            cell.FileIconImageView.image = #imageLiteral(resourceName: "safeBox")
            break
        case "pdf":
            cell.FileIconImageView.image = #imageLiteral(resourceName: "icons8-Play_50")
        default:
            cell.FileIconImageView.image = #imageLiteral(resourceName: "todolist-30")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fileNameString = self.files[indexPath.row].filename as NSString
        if(fileNameString.pathExtension.lowercased() == "pdf" || fileNameString.pathExtension.lowercased() == "docx" || fileNameString.pathExtension.lowercased() == "xlsx" || fileNameString.pathExtension.lowercased() == "pptx" ){
            
            let resource = self.files[indexPath.row].downloadUrl as NSString
            
            
            self.performSegue(withIdentifier: "openPDFSegue", sender: nil)
        }else if(fileNameString.pathExtension.lowercased() == "jpg" || fileNameString.pathExtension.lowercased() == "png" || fileNameString.pathExtension.lowercased() == "gif"){
            var image:UIImage? = nil
            if let url = NSURL(string: self.files[indexPath.row].downloadUrl) {
                if let data = NSData(contentsOf: url as URL) {
                    image = UIImage(data: data as Data)!
                    if(image != nil){
                        lightboxController = LightboxController(images: [LightboxImage(image: image!)], startIndex: 0)
                        
                        lightboxController.pageDelegate = self
                        lightboxController.dismissalDelegate = self
                        
                        lightboxController.dynamicBackground = false
                        LightboxConfig.CloseButton.text = "Cerrar"
                        
                        present(lightboxController, animated: true, completion: nil)
                    }else{
                        self.view.makeToast("Imagen con formato dañado.")
                    }
                    

                }
            }
            
        }else if(fileNameString.pathExtension.lowercased() == "mp4"){
            let size = CGSize(width: 200, height: 200)
            let color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setFill()
            UIRectFill(rect)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            lightboxController = LightboxController(images: [LightboxImage(
                image: image,
                text: "",
                videoURL: NSURL(string: self.files[indexPath.row].downloadUrl!)! as URL
                )], startIndex: 0)
            
            lightboxController.pageDelegate = self
            lightboxController.dismissalDelegate = self
            
            lightboxController.dynamicBackground = false
            LightboxConfig.CloseButton.text = "Cerrar"
            
            present(lightboxController, animated: true, completion: nil)

        }else if(fileNameString.pathExtension.lowercased() == "mp3"){
            let url = NSURL(string: self.files[indexPath.row].downloadUrl)
            do {
                
                let playerItem = AVPlayerItem(url: url! as URL)
                
                self.player = try AVPlayer(playerItem:playerItem)
                self.player!.volume = 1.0
                self.player!.play()
                
                let alert = UIAlertController(title: "Reproduciendo", message: self.files[indexPath.row].filename!, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Detener", style: .destructive, handler: { (alert) in
                    self.player.pause()
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            } catch let error as NSError {
                player = nil
                print(error.localizedDescription)
            } catch {
                print("AVAudioPlayer init failed")
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openPDFSegue"{
            if let indexPath = self.filesCollectionView.indexPathsForSelectedItems{
                let selectedItem = self.files[indexPath[0].row]
                let webView = segue.destination as! PDFViewController
                webView.url = selectedItem.downloadUrl
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let newFile:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let alert = UIAlertController(title: "Nombre del archivo", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Nombre del archivo"
        }
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { (_alert) in
            let fileNameTextField = alert.textFields?[0]
            
            let fileName = (fileNameTextField?.text)!
            let data = UIImagePNGRepresentation(newFile.resizeImage()) as NSData?
            Constants.FirStorage.STORAGEREF.child("users/\((store.state.UserState.user?.id)!)").child("safebox/\(fileName).png").put(data! as Data, metadata: nil){ metadata, error in
                if error != nil{
                    print(error.debugDescription)
                }else{
                    if let downloadUrl = metadata?.downloadURL()?.absoluteString{
                        StorageService.Instance().save(url: downloadUrl, data: data as Data?)
                        let downloadURL = downloadUrl
                        
                        //Save to database
                        let newSafeBoxFile = SafeBoxFile(filename: "\(fileName).png", downloadUrl: downloadURL)
                        store.dispatch(InsertSafeBoxFileAction(item: newSafeBoxFile))
                        store.subscribe(self){
                            subscription in subscription.safeBoxState //Cosa cochi que debo de hacer porque el imagePicker y el documentPicker desinscriben la vista
                        }

                    }
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {

        let outerURL = url as URL
        print("The Url is : \(outerURL)")
        var fileName:String = ""
        var downloadURL:String = ""
        
        let alert = UIAlertController(title: "Nombre del archivo", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { (_alert) in
            //Mandar la respuesta
            let fileNameTextField = alert.textFields?[0]
            
            fileName = (fileNameTextField?.text)!
            
            let fileURL = NSURL(string: "\(outerURL)")
            let request = NSURLRequest(url: fileURL! as URL)
            let mainQueue = OperationQueue.main
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    
                    Constants.FirStorage.STORAGEREF.child("users/\((store.state.UserState.user?.id)!)").child("safebox/\(fileName).\(outerURL.pathExtension)").put(data!, metadata: nil){ metadata, error in
                        if error != nil{
                            print(error.debugDescription)
                        }else{
                            if let downloadUrl = metadata?.downloadURL()?.absoluteString{
                                StorageService.Instance().save(url: downloadUrl, data: data)
                                downloadURL = downloadUrl
                                
                                //Save to database
                                let newSafeBoxFile = SafeBoxFile(filename: "\(fileName).\(outerURL.pathExtension)", downloadUrl: downloadURL)
                                store.dispatch(InsertSafeBoxFileAction(item: newSafeBoxFile))
                                store.subscribe(self){
                                    subscription in subscription.safeBoxState //Cosa cochi que debo de hacer porque el imagePicker y el documentPicker desinscriben la vista
                                }

                            }
                        }
                    }
                    
                    
                } else {
                    print("rip")
                }
            })
        }))
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Nombre del archivo"
        }
        
        present(alert, animated: true, completion:nil)
        
    }
    
    public func documentMenu(_ documentMenu:     UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        print("we cancelled")
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        print("dismiss")
    }
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        //        self.selectedImage = page
    }
}

extension IndexViewController: StoreSubscriber{
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFlag), name: notCenter.BACKGROUND_NOTIFICATION, object: nil)
        verify()
        service.SAFEBOX_SERVICE.initObservers(ref: "safebox/\(userId!)", actions: [.childAdded, .childChanged, .childRemoved])
        
        store.subscribe(self){
            subscription in subscription.safeBoxState
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        flag = false
        
        store.state.safeBoxState.status = .none
        store.unsubscribe(self)
        service.SAFEBOX_SERVICE.removeHandles()

        
        NotificationCenter.default.removeObserver(self, name: notCenter.BACKGROUND_NOTIFICATION, object: nil);
    }
    
    func newState(state: SafeBoxState) {
        switch state.status {
        case .failed:
            self.view.makeToast("Ocurrió un error, intente nuevamente")
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            self.view.hideToastActivity()
            self.filesCollectionView.reloadData()
            break
        case .none:
            break
        default:
            break
        }
        
        files = state.safeBoxFiles[userId!] ?? []
        self.filesCollectionView.reloadData()
    }
    
    
}

extension IndexViewController :  UIImagePickerControllerDelegate  {
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Saved!", message: "Image saved successfully", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

