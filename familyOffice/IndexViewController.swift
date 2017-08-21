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

class IndexViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UIDocumentMenuDelegate,UIDocumentPickerDelegate,UINavigationControllerDelegate,LightboxControllerPageDelegate,LightboxControllerDismissalDelegate  {
    
    var flag = false
    var files:[SafeBoxFile] = []
    var userId = store.state.UserState.user?.id
    
    var lightboxController = LightboxController()
    
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
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func handleNew() -> Void {
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF), String(kUTTypeData)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
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
        print(ext.pathExtension)
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
            print("es PDF")
            let resource = self.files[indexPath.row].downloadUrl as NSString
            print(resource.deletingPathExtension)
            
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
    typealias StoreSubscriberStateType = SafeBoxState
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFlag), name: notCenter.BACKGROUND_NOTIFICATION, object: nil)
        
        service.SAFEBOX_SERVICE.initObservers(ref: "safebox/\((store.state.UserState.user?.id)!)", actions: [.childAdded, .childChanged, .childRemoved])
        
        store.subscribe(self){
            state in state.safeBoxState
        }
        
        verify()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        flag = false
        
        store.state.safeBoxState.status = .none
        store.unsubscribe(self)
        service.SAFEBOX_SERVICE.removeHandles()

        
        NotificationCenter.default.removeObserver(self, name: notCenter.BACKGROUND_NOTIFICATION, object: nil);
    }
    
    func newState(state: SafeBoxState) {
        files = state.safeBoxFiles[userId!] ?? []
        switch state.status {
        case .failed:
            self.view.makeToast("Ocurrió un error, intente nuevamente")
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            self.view.hideToastActivity()
            filesCollectionView.reloadData()
            break
        case .none:
            break
        default:
            break
        }
        filesCollectionView.reloadData()
    }
    
    
}

