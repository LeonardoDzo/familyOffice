//
//  RegisterFamilyViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 04/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import ReSwift
class RegisterFamilyViewController: UIViewController, FamilyBindable, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, ContactsProtocol {
    var family: Family!
    var users: [User]! = []
    
    /// Variable para saber si cambio la foto o no para editar
    var change = false
    
    typealias StoreSubscriberStateType = FamilyState
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var schearButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTxt: textFieldStyleController!
    @IBOutlet weak var contentview: UIView!
    
    var Image: UIImageView!
    var blurImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        Image = UIImageView()
        blurImageView.contentMode = UIViewContentMode.scaleAspectFill
        Image.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        blurImageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        Image.isUserInteractionEnabled = true
        scrollView.addSubview(blurImageView)
        scrollView.addSubview(Image)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.loadImage(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        Image.addGestureRecognizer(tapGestureRecognizer)
        contentview.formatView()
        scrollView.formatView()
    }
    
    func loadImage(_ recognizer: UITapGestureRecognizer){
        let imagePicker = UIImagePickerController()
        self.Image.image = nil
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func handleClickContact(_ sender: UIButton) {
        self.performSegue(withIdentifier: "contactsSegue", sender: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.Image.image = nil
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        scrollView.zoomScale = 1
        self.Image.image = image
        change = true
        blurImageView.image = image
        Image.contentMode = UIViewContentMode.center
        Image.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: scrollView.frame.size.height)
        scrollView.contentSize = image.size
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = minScale
        centerScrollViewContents()
        
        //blur
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurImageView.addSubview(blurEffectView)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func centerScrollViewContents(){
        let boundsSize = scrollView.bounds.size
        var contentsFrame = Image.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        }else{
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        }else{
            contentsFrame.origin.y = 0
        }
        Image.frame = contentsFrame
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return Image
    }
    
    
    func cropAndSave(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.main.scale)
        let offset = scrollView.contentOffset
        UIGraphicsGetCurrentContext()?.translateBy(x: -offset.x, y: -offset.y)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        UIGraphicsEndImageContext()
        
        if !users.contains((store.state.UserState.user)!){
            users.append((store.state.UserState.user)!)
        }
        
        guard let name = nameTxt.text, !name.isEmpty else {
            error()
            return
        }
        guard let image = Image, image.image != nil else {
            error()
            return
        }
        self.family.name = name
        self.family.members = self.users.map({ $0.id})
        self.family.admin = (FIRAuth.auth()?.currentUser?.uid)!
        service.UTILITY_SERVICE.disabledView()
        if family.id.isEmpty{
            save()
            return
        }
        
        edit()
    }
    func edit() -> Void {
        if(!(nameTxt.text?.isEmpty)!){
            if change {
                store.dispatch(InsertFamilyAction(family: family, img: Image.image!))
                return
            }
            store.dispatch(InsertFamilyAction(family: family))
        }else{
            error()
        }
    }
    func save() -> Void {
        
        if(Image.image != nil && !(nameTxt.text?.isEmpty)!){
            self.family.name = self.nameTxt.text!
            self.family.members = self.users.map({ $0.id})
            self.family.admin = (FIRAuth.auth()?.currentUser?.uid)!
            
            service.UTILITY_SERVICE.disabledView()
            store.dispatch(InsertFamilyAction(family: family, img: Image.image!))
        }else{
            error()
        }
    }
    func error() -> Void {
        service.UTILITY_SERVICE.enabledView()
        self.view.hideToastActivity()
        let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func selected(users: [User]) {
        self.users = users
        self.collectionView.reloadData()
    }
    
}
extension RegisterFamilyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellMember", for: indexPath) as! memberSelectedCollectionViewCell
        let user = users[indexPath.row]
        cell.bind(userModel: user)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        users.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        family.name = nameTxt.text
        if segue.identifier ==  "contactsSegue" {
            
            if let destinationNavController = (segue.destination as? UINavigationController){
                if let vc = destinationNavController.viewControllers.first as? ContactsViewController{
                    vc.contactDelegate = self
                }
            }
        }
    }
    
}
extension RegisterFamilyViewController : StoreSubscriber {
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            state in
            state.FamilyState
        }
        
        self.bind()
        if let family =  store.state.FamilyState.families.family(fid: self.family.id) {
            
            family.members.forEach({uid in
                if let user = service.USER_SVC.getUser(byId: uid) {
                    if !self.users.contains(user) {
                        self.users.append(user)
                    }
                }
                
            })
        }
        self.setupNavBar()
        self.collectionView.reloadData()
        self.centerScrollViewContents()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    func newState(state: FamilyState) {
        self.view.hideToastActivity()
        
        switch state.status {
        case .failed:
            error()
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            service.UTILITY_SERVICE.enabledView()
            _ = self.navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
    }
    
    func setupNavBar() -> Void {
        if family.id.isEmpty {
            let saveButton = UIBarButtonItem(title: "Crear", style: .plain, target: self, action: #selector(self.cropAndSave(_:)))
            navigationItem.rightBarButtonItems = [saveButton]
            navigationItem.title = "Crear Familia"
        }else{
            let update = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.cropAndSave(_:)))
            navigationItem.rightBarButtonItems = [update]
            navigationItem.title = "Actualizar Familia"
        }
        
    }
}
