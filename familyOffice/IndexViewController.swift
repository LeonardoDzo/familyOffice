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

class IndexViewController: UIViewController, UICollectionViewDataSource,UINavigationControllerDelegate, UICollectionViewDelegate,UIDocumentMenuDelegate,UIDocumentPickerDelegate,LightboxControllerPageDelegate,LightboxControllerDismissalDelegate,UIGestureRecognizerDelegate  {
    
    var flag = false
    var files:[SafeBoxFile] = []
    var userId = getUser()?.id
    var player:AVPlayer!
    var folders = ["root"]
    var currentFolder = "root"
    var currentFolderId = "root"
    
    @IBOutlet weak var searchBarFiles: UISearchBar!
    @IBOutlet weak var tabBar: UITabBar!
    
    var lightboxController = LightboxController()
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var filesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        let barButton = UIBarButtonItem(title: "Atras", style: .plain, target: self, action: #selector(self.back))
        let newButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_more_button"), style: .plain, target: self, action: #selector(self.handleMore))
        self.navigationItem.leftBarButtonItem = barButton
        self.navigationItem.rightBarButtonItem = newButton
        
        tabBar.selectedItem = tabBar.items?[0]
        
        // Do any additional setup after loading the view.
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = #colorLiteral(red: 0.9598663449, green: 0.7208504081, blue: 0.1197796389, alpha: 1)
        tabBar.tintColor = #colorLiteral(red: 0.9598663449, green: 0.7208504081, blue: 0.1197796389, alpha: 1)
        self.title = "Caja fuerte"
        nav?.titleTextAttributes = [NSAttributedStringKey.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        nav?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        let longPressEvent = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressOnCell(gesture:)))
        longPressEvent.minimumPressDuration = 0.5
        self.filesCollectionView.addGestureRecognizer(longPressEvent)
        
        if( traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView: self.filesCollectionView)
        } else {
            _ = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressOnCell))
        }
    }
    
    @objc func handleMore() {
        let alert = UIAlertController(title: "Acciones", message: "¿Qué desea realizar?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Nuevo archivo", style: .default , handler: { (action) in
            self.handleNew()
        }))
        
        alert.addAction(UIAlertAction(title: "Nueva carpeta", style: .default , handler: { (action) in
            self.newFolder()
        }))
        
//        alert.addAction(UIAlertAction(title: "Cambiar vista?", style: .default, handler: { (action) in
//        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        alert.modalPresentationStyle = UIModalPresentationStyle.currentContext
        
        present(alert, animated: true) {
        }
    }
    
    @objc func handleLongPressOnCell(gesture: UILongPressGestureRecognizer){
//        if gesture.state != UIGestureRecognizerState.ended {
//            return
//        }
        
        let p = gesture.location(in: self.filesCollectionView)
        let indexPath = self.filesCollectionView.indexPathForItem(at: p)
        
        if let index = indexPath {
            let file = self.files[index.row]
            if NSString(string: file.filename).pathExtension == ""{
                let alert = UIAlertController(title: file.filename, message: "¿Qué acción desea realizar?", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
                
                alert.addAction(UIAlertAction(title: "Mover", style: .default, handler: { (action) in
                    self.performSegue(withIdentifier: "showDirTree", sender: file)
                }))
                
                alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive, handler: { (action) in
                    let confirmationAlert = UIAlertController(title: "Eliminar carpeta", message: "", preferredStyle: .alert)
                    
                    confirmationAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action) in
                        return
                    }))
                    
                    confirmationAlert.addAction(UIAlertAction(title: "Aceptar", style: .destructive, handler: { (alert) in
                        store.dispatch(DeleteSafeBoxFileAction(item: file))
                    }))
                    
                    self.present(confirmationAlert, animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }else{
                return
            }
        } else {
            return
        }
    }
    @objc func updateFlag() {
        flag  = false
        verify()
    }
    
    func verify() -> Void {
        if !flag {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func back() -> Void {
        if self.currentFolder == "root"{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.currentFolder = self.folders.popLast()!
            let folder = self.files.first(where: {$0.filename == self.currentFolder})
            self.currentFolderId = folder?.id ?? "root"
            self.title = self.currentFolder == "root" ? "Caja fuerte" : self.currentFolder
            files = getFiles()
            self.filesCollectionView.reloadData()
        }
        
    }
    
    
    func newFolder() -> Void {
        let alert = UIAlertController(title: "Agregar carpeta", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Nombre de la carpeta"
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Crear", style: .default, handler: { (_alert) in
            let fileNameTextField = alert.textFields?[0]
            
            let fileName = (fileNameTextField?.text)!
            
            let newSafeBoxFile = SafeBoxFile(filename: fileName, downloadUrl: "", parent: self.currentFolderId, type: "folder")
            store.dispatch(InsertSafeBoxFileAction(item: newSafeBoxFile))
        }))
        
        self.present(alert, animated: true) {
        }
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
    
    //MARK: - CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let ext:NSString = self.files[indexPath.row].filename! as NSString
        let file:SafeBoxFile = self.files[indexPath.row]
        
        switch(ext.pathExtension){
            case "":
                let cell = filesCollectionView.dequeueReusableCell(withReuseIdentifier: "safeboxFolderID", for: indexPath) as! FolderCollectionViewCell
                cell.folderNameLabel.text = file.filename
                return cell
            case "png", "jpg", "jpeg":
                let cell = filesCollectionView.dequeueReusableCell(withReuseIdentifier: "safeboxImageID", for: indexPath) as! ImageCollectionViewCell
                cell.imageNameLabel.text = file.filename
                cell.imgView.loadImage(urlString: file.downloadUrl!)
                return cell
            default:
                let cell = filesCollectionView.dequeueReusableCell(withReuseIdentifier: "safeboxFileID", for: indexPath) as! FileCollectionViewCell
                cell.fileNameLabel.text = file.filename
                cell.fileExtLabel.text = ext.pathExtension
                let color: UIColor
                switch ext.pathExtension {
                case "docx", "doc":
                    color = UIColor.SafeBox.docx
                case "gsheet", "xls", "xlsx":
                    color = UIColor.SafeBox.xlsx
                case "pdf":
                    color = UIColor.SafeBox.pdf
                default:
                    color = UIColor.gray
                }
                cell.bgView.backgroundColor = color
                return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let fileNameString = self.files[indexPath.row].filename as NSString
        if(fileNameString.pathExtension.lowercased() == "jpg" || fileNameString.pathExtension.lowercased() == "png" || fileNameString.pathExtension.lowercased() == "gif"){
            var aux = 0
            var index = 0
            let images:[LightboxImage] = self.files.filter({$0.thumbnail != ""}).map({ (file) -> LightboxImage in
                if file.id != self.files[indexPath.row].id {
                    aux += 1
                }else{
                    index = aux
                }
                return LightboxImage(imageURL: URL(string: file.downloadUrl)!, text: file.filename, videoURL: nil)
            })
            self.lightboxController = LightboxController(images: images, startIndex: index)
            
            self.lightboxController.pageDelegate = self
            self.lightboxController.dismissalDelegate = self
            
            self.lightboxController.dynamicBackground = false
            LightboxConfig.CloseButton.text = "Cerrar"
            
            self.present(self.lightboxController, animated: true, completion: nil)

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

        }else if(fileNameString.pathExtension.lowercased() == ""){
            self.folders.append(self.currentFolder)
            self.currentFolderId = self.files[indexPath.row].id!
            self.currentFolder = fileNameString as String
            self.title = self.currentFolder == "root" ? "Caja fuerte" : self.currentFolder
            print("Current Folder: \(self.currentFolder)")
            files = self.getFiles()
            filesCollectionView.reloadData()
        }else {
            self.performSegue(withIdentifier: "openPDFSegue", sender: nil)
        }
        self.searchBarFiles.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openPDFSegue"{
            if let indexPath = self.filesCollectionView.indexPathsForSelectedItems{
                let selectedItem = self.files[indexPath[0].row]
                let webView = segue.destination as! PDFViewController
                webView.file = selectedItem
            }
        }else if segue.identifier == "showDirTree" {
            let selectedFile = sender as! SafeBoxFile
//            print(selectedFile)
            self.title = "Cancelar"
            let view = segue.destination as! MoveFileViewController
            view.file = selectedFile
            view.tree = self.folders
            view.currentFolder = self.currentFolder
            view.currentFolderId = self.currentFolderId
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
            let data = UIImagePNGRepresentation(newFile.resizeToLarge()) as NSData?
            let min_data = UIImagePNGRepresentation(newFile.resizeToSmall()) as NSData?

            Constants.FirStorage.STORAGEREF.child("users/\((getUser()?.id)!)").child("safebox/\(fileName).png").putData(data! as Data, metadata: nil, completion: { metadata, error in
                if error != nil{
                    print(error.debugDescription)
                }else{
                    Constants.FirStorage.STORAGEREF.child("users/\((getUser()?.id)!)").child("safebox/\(fileName)_small.png").putData(min_data! as Data, metadata: nil, completion: { md, err in
                        if err != nil{
                            print(err.debugDescription)
                        }
                        if let downloadUrl = metadata?.downloadURL()?.absoluteString{
                            StorageService.Instance().save(url: downloadUrl, data: data as Data?)
                            let downloadURL = downloadUrl
                            
                            if let download_min = md?.downloadURL()?.absoluteString{
                                StorageService.Instance().save(url: download_min, data: min_data as Data?)
                                //Save to database
                                let newSafeBoxFile = SafeBoxFile(filename: "\(fileName).png", downloadUrl: downloadURL,thumbnail:download_min,parent: self.currentFolderId, type: "file")
                                store.dispatch(InsertSafeBoxFileAction(item: newSafeBoxFile))
                                store.subscribe(self){

                                    $0.select({ (s)  in
                                        s.safeBoxState
                                    }) //Cosa cochi que debo de hacer porque el imagePicker y el documentPicker desinscriben la vista
                                }
                            }
                        }
                    })
                }
            })
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
            let userId = getUser()?.id
            
            let fileURL = NSURL(string: "\(outerURL)")
            let request = NSURLRequest(url: fileURL! as URL)
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, urlResponse, err) in
                print("Entered the completionHandler")
                if err == nil {
                    

                    Constants.FirStorage.STORAGEREF.child("users/\((userId)!)").child("safebox/\(fileName).\(outerURL.pathExtension)").putData(data!, metadata: nil, completion: { metadata, error in

                        if error != nil{
                            print(error.debugDescription)
                        }else{
                            if let downloadUrl = metadata?.downloadURL()?.absoluteString{
                                StorageService.Instance().save(url: downloadUrl, data: data)
                                downloadURL = downloadUrl
                                
                                //Save to database
                                let newSafeBoxFile = SafeBoxFile(filename: "\(fileName).\(outerURL.pathExtension)", downloadUrl: downloadURL, parent: self.currentFolderId, type: "file")
                                store.dispatch(InsertSafeBoxFileAction(item: newSafeBoxFile))
                                store.subscribe(self){

                                    $0.select {
                                        s in s.safeBoxState
                                    } //Cosa cochi que debo de hacer porque el imagePicker y el documentPicker desinscriben la vista

                                }
                                
                            }
                        }
                    })
                    
                    
                } else {
                    print("rip")
                }

            }.resume()
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
    
    
    
    func getFiles() -> [SafeBoxFile] {
        let selectedTabBarItem = self.tabBar.selectedItem?.tag
        print(selectedTabBarItem!)
        let folders = store.state.safeBoxState.safeBoxFiles[userId!]?.filter({$0.type == "folder" && $0.parent == self.currentFolderId && self.filterByTabBar(selectedItem: selectedTabBarItem!, file: $0)}).sorted(by: { (a, b) -> Bool in return a.filename < b.filename}) ?? []
        let newFiles = store.state.safeBoxState.safeBoxFiles[userId!]?.filter({$0.type == "file" && $0.parent == self.currentFolderId && self.filterByTabBar(selectedItem: selectedTabBarItem!, file: $0)}).sorted(by: { (a, b) -> Bool in return a.filename < b.filename}) ?? []
        let total = folders + newFiles
        
        let backgroundnoevents = UIImageView(frame: self.view.frame)
        backgroundnoevents.tag = 100
        if total.count == 0 {
            backgroundnoevents.image = #imageLiteral(resourceName: "no-files")
            self.filesCollectionView.backgroundView = backgroundnoevents
            backgroundnoevents.contentMode = .center
        } else {
            self.filesCollectionView.backgroundView = nil
        }
        return total
    }
}

extension IndexViewController: StoreSubscriber{
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFlag), name: notCenter.BACKGROUND_NOTIFICATION, object: nil)
        verify()
        service.SAFEBOX_SERVICE.initObservers(ref: "safebox/\(userId!)", actions: [.childAdded, .childChanged, .childRemoved])
        self.title = "Caja fuerte"
        store.subscribe(self){

            $0.select {
                s in s.safeBoxState
            }
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
        files = self.getFiles()
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

extension IndexViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            //reload your data source if necessary
            files = files.filter({$0.filename.lowercased().contains(searchBar.text!.lowercased()) && $0.parent == self.currentFolderId})
            filesCollectionView.reloadData()
        }else{
            files = store.state.safeBoxState.safeBoxFiles[userId!] ?? []
            filesCollectionView.reloadData()
        }
        

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            //reload your data source if necessary
            files = self.getFiles()
            filesCollectionView.reloadData()
        }else{
            files = files.filter({$0.filename.lowercased().contains(searchBar.text!.lowercased()) && $0.parent == self.currentFolderId})
            filesCollectionView.reloadData()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        files = store.state.safeBoxState.safeBoxFiles[userId!]?.filter({$0.parent == self.currentFolderId}) ?? []
        filesCollectionView.reloadData()
    }
    
    
}

extension IndexViewController: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = filesCollectionView?.indexPathForItem(at: location) else {return nil}
        print(indexPath)
        guard let cell = filesCollectionView?.cellForItem(at: indexPath) else {return nil}
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "PDFViewController") as? PDFViewController else {return nil}
        
        var file = self.files[indexPath.row]
        detailVC.file = file
        if NSString(string: file.filename).pathExtension == "" {
            return nil
        }
        
        detailVC.previewAct.append(
            UIPreviewAction(title: "Compartir...", style: .default, handler: { (UIPreviewAction, UIViewController) in
                self.view.makeToastActivity(.center)
                let fileURL = NSURL(string: self.files[indexPath.row].downloadUrl!)!
                
                print(fileURL)
                let request = NSURLRequest(url: fileURL as URL)
                _ = URLSession.shared.dataTask(with: request as URLRequest) { (data, urlResponse, err) in
                    if err == nil {
                        let fileManager = FileManager.default
                        do {
                            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                            let fileUrl = documentDirectory.appendingPathComponent(self.files[indexPath.row].filename)
                            try data?.write(to: fileUrl)
                            let sharedObjects:[AnyObject] = [fileUrl as AnyObject]
                            let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
                            
                            activityViewController.popoverPresentationController?.sourceView = self.view
                            self.present(activityViewController, animated: true, completion: {
                                do{
                                    self.view.hideToastActivity()
                                }catch _ {
                                    print("rip")
                                }
                            })
                        } catch {
                            print(error)
                        }
                        
                    } else {
                        print("rip")
                    }
                    }.resume()
                
            })
        )

        detailVC.previewAct.append(UIPreviewAction(title: "Renombrar", style: .default, handler: { (UIPreviewAction, UIViewController) in
            let alert = UIAlertController(title: "Renombrar", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { (_alert) in
                let fileNameTextField = alert.textFields?[0]
                let ext = NSString(string: file.filename).pathExtension
                file.filename = "\((fileNameTextField?.text)!).\(ext)"
                
                store.dispatch(UpdateSafeBoxFileAction(item: file))
                store.subscribe(self){

                    $0.select {
                        s in s.safeBoxState
                    }
                }
            }))
            
            alert.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Nuevo nombre"
            }
            
            self.present(alert, animated: true, completion:nil)

        }))
        
        detailVC.previewAct.append(UIPreviewAction(title: "Mover", style: .default, handler: { (UIPreviewAction, UIViewController) in
            self.performSegue(withIdentifier: "showDirTree", sender: self.files[indexPath.row])
        }))
        
        detailVC.previewAct.append(UIPreviewAction(title: "Eliminar", style: .destructive , handler: { (UIPreviewAction, UIViewController) in
            store.dispatch(DeleteSafeBoxFileAction(item: self.files[indexPath.row]))
            store.subscribe(self){

                $0.select {
                    s in s.safeBoxState
                }
            }

        }))
        
        
        
        detailVC.preferredContentSize = CGSize(width: 0.0, height: 600)
        
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
        
    }
}

extension IndexViewController: UITabBarDelegate {
    func isImage(file: SafeBoxFile) -> Bool {
        let ext = NSString(string: file.filename).pathExtension
        return ext == "png" || ext == "jpg" || ext == "gif"
    }
    
    func isFolder(file: SafeBoxFile) -> Bool{
        let ext = NSString(string: file.filename).pathExtension
        return ext == ""
    }
    
    func filterByTabBar(selectedItem: Int, file: SafeBoxFile) -> Bool {
        switch selectedItem {
        case 0:
            return true
        case 1:
            return !self.isImage(file: file)
        case 2:
            return self.isImage(file: file) || self.isFolder(file: file)
        default: return true
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            self.files = getFiles()
            break
        case 1:
            self.files = getFiles().filter({ (file) -> Bool in
                let ext = NSString(string: file.filename).pathExtension
                return !isImage(file: file)
            })
            break
        case 2:
            self.files = getFiles().filter({ (file) -> Bool in
                let ext = NSString(string: file.filename).pathExtension
                return isImage(file: file) || isFolder(file: file)
            })
            break
        default:
            break
        }
        self.filesCollectionView.reloadData()
    }
}
