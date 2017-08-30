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
    
    @IBOutlet weak var dirTreeLbl: UILabel!
    var flag = false
    var files:[SafeBoxFile] = []
    var userId = store.state.UserState.user?.id
    var player:AVPlayer!
    var currentFolder = "root"
    var directoriesTree = ["","root"]
    
    @IBOutlet weak var searchBarFiles: UISearchBar!
    
    var lightboxController = LightboxController()
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var filesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        let barButton = UIBarButtonItem(title: "Atras", style: .plain, target: self, action: #selector(self.handleBack))
        self.navigationItem.leftBarButtonItem = barButton
        // Do any additional setup after loading the view.
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.3137395978, green: 0.1694342792, blue: 0.5204931498, alpha: 1)]
        self.navigationItem.title = "Caja Fuerte"
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.filesCollectionView.addGestureRecognizer(swipeRight)
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressOnCell))
        lpgr.minimumPressDuration = 0.25
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.filesCollectionView.addGestureRecognizer(lpgr)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleNew))
        addButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        let addFolderButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.newFolder))
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Home"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        backButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        self.navigationItem.rightBarButtonItems = [addFolderButton, addButton]
        
        self.dirTreeLbl.text = directoriesTree.joined(separator: "/")
        
        if( traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView: self.filesCollectionView)
        }
    }
    
    func handleLongPressOnCell(gesture: UILongPressGestureRecognizer){
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
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        print ("Swiped right")
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.right:
                
                if(self.currentFolder != "root"){
                    self.directoriesTree.popLast()
                    self.currentFolder = self.directoriesTree[self.directoriesTree.count - 1]
                    print(self.directoriesTree)
                    self.dirTreeLbl.text = directoriesTree.joined(separator: "/")
                    print("Current Folder: \(self.currentFolder)")
                    files = (store.state.safeBoxState.safeBoxFiles[userId!]?.filter({$0.parent == self.currentFolder}))!
                    self.filesCollectionView.reloadData()
                }
                break
            default:
                break
            }
        }
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
    
    
    func newFolder() -> Void {
        let alert = UIAlertController(title: "Agregar carpeta", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Nombre de la carpeta"
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Crear", style: .default, handler: { (_alert) in
            let fileNameTextField = alert.textFields?[0]
            
            let fileName = (fileNameTextField?.text)!
            
            let newSafeBoxFile = SafeBoxFile(filename: fileName, downloadUrl: "", parent: self.currentFolder)
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
        let file = self.files[indexPath.row]
        cell.fileNameLabel.text = file.filename
        let ext:NSString = self.files[indexPath.row].filename! as NSString
        switch ext.pathExtension {
        case "png":
            if file.thumbnail! != ""{
                if let url = NSURL(string: file.thumbnail!) {
                    if let data = NSData(contentsOf: url as URL) {
                         cell.FileIconImageView.image = UIImage(data: data as Data)!
                    }
                }
            }
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
        if(fileNameString.pathExtension.lowercased() == "pdf" || fileNameString.pathExtension.lowercased() == "docx" || fileNameString.pathExtension.lowercased() == "xlsx" || fileNameString.pathExtension.lowercased() == "pptx" || fileNameString.pathExtension.lowercased() == "mp3" ){
            
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

        }else if(fileNameString.pathExtension.lowercased() == ""){
            self.currentFolder = fileNameString as String
            self.directoriesTree.append(fileNameString as String)
            self.dirTreeLbl.text = directoriesTree.joined(separator: "/")
            print(self.directoriesTree)
            print("Current Folder: \(self.currentFolder)")
            files = store.state.safeBoxState.safeBoxFiles[userId!]?.filter({$0.parent == self.currentFolder}) ?? []
            filesCollectionView.reloadData()
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
            let view = segue.destination as! MoveFileViewController
            view.file = selectedFile
            view.tree = self.directoriesTree
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
            Constants.FirStorage.STORAGEREF.child("users/\((store.state.UserState.user?.id)!)").child("safebox/\(fileName).png").put(data! as Data, metadata: nil){ metadata, error in
                if error != nil{
                    print(error.debugDescription)
                }else{
                    Constants.FirStorage.STORAGEREF.child("users/\((store.state.UserState.user?.id)!)").child("safebox/\(fileName)_small.png").put(min_data! as Data, metadata: nil){ md, err in
                        if err != nil{
                            print(err.debugDescription)
                        }
                        if let downloadUrl = metadata?.downloadURL()?.absoluteString{
                            StorageService.Instance().save(url: downloadUrl, data: data as Data?)
                            let downloadURL = downloadUrl
                            
                            if let download_min = md?.downloadURL()?.absoluteString{
                                StorageService.Instance().save(url: download_min, data: min_data as Data?)
                                //Save to database
                                let newSafeBoxFile = SafeBoxFile(filename: "\(fileName).png", downloadUrl: downloadURL,thumbnail:download_min,parent: self.currentFolder)
                                store.dispatch(InsertSafeBoxFileAction(item: newSafeBoxFile))
                                store.subscribe(self){
                                    subscription in subscription.safeBoxState //Cosa cochi que debo de hacer porque el imagePicker y el documentPicker desinscriben la vista
                                }
                            }
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
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, urlResponse, err) in
                print("Entered the completionHandler")
                if err == nil {
                    
                    Constants.FirStorage.STORAGEREF.child("users/\((store.state.UserState.user?.id)!)").child("safebox/\(fileName).\(outerURL.pathExtension)").put(data!, metadata: nil){ metadata, error in
                        if error != nil{
                            print(error.debugDescription)
                        }else{
                            if let downloadUrl = metadata?.downloadURL()?.absoluteString{
                                StorageService.Instance().save(url: downloadUrl, data: data)
                                downloadURL = downloadUrl
                                
                                //Save to database
                                let newSafeBoxFile = SafeBoxFile(filename: "\(fileName).\(outerURL.pathExtension)", downloadUrl: downloadURL, parent: self.currentFolder)
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
        
        files = state.safeBoxFiles[userId!]?.filter({$0.parent == self.currentFolder}) ?? []
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
            files = files.filter({$0.filename.lowercased().contains(searchBar.text!.lowercased()) && $0.parent == self.currentFolder})
            filesCollectionView.reloadData()
        }else{
            files = store.state.safeBoxState.safeBoxFiles[userId!] ?? []
            filesCollectionView.reloadData()
        }
        

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            //reload your data source if necessary
            files = store.state.safeBoxState.safeBoxFiles[userId!]?.filter({$0.parent == self.currentFolder}) ?? []
            print(files.count)
            filesCollectionView.reloadData()
        }else{
            files = files.filter({$0.filename.lowercased().contains(searchBar.text!.lowercased()) && $0.parent == self.currentFolder})
            filesCollectionView.reloadData()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        files = store.state.safeBoxState.safeBoxFiles[userId!]?.filter({$0.parent == self.currentFolder}) ?? []
        filesCollectionView.reloadData()
    }
    
    
}

extension IndexViewController: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = filesCollectionView?.indexPathForItem(at: location) else {return nil}
        
        guard let cell = filesCollectionView?.cellForItem(at: indexPath) else {return nil}
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "PDFViewController") as? PDFViewController else {return nil}
        
        let file = self.files[indexPath.row]
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
                                }catch{
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

        
        detailVC.previewAct.append(UIPreviewAction(title: "Mover", style: .default, handler: { (UIPreviewAction, UIViewController) in
            self.performSegue(withIdentifier: "showDirTree", sender: self.files[indexPath.row])
        }))
        
        detailVC.previewAct.append(UIPreviewAction(title: "Eliminar", style: .destructive , handler: { (UIPreviewAction, UIViewController) in
            store.dispatch(DeleteSafeBoxFileAction(item: self.files[indexPath.row]))
            store.subscribe(self){
                subscription in subscription.safeBoxState //Cosa cochi que debo de hacer porque el imagePicker y el documentPicker desinscriben la vista
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

