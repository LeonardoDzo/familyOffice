//
//  EditItemViewController.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 7/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import ReSwift
import ReSwiftRouter

class EditItemViewController: UIViewController,UINavigationControllerDelegate,UIGestureRecognizerDelegate,DateProtocol {
    var item:ToDoList.ToDoItem = ToDoList.ToDoItem(title: "", photoUrl: "", status: "Pendiente", endDate: "")
    var imagePicker: UIImagePickerController!
    var endDate: String?
    var initialPhoto: String!
    var tookPhoto:Bool = false
    var isNewItem:Bool = false
    
    @IBOutlet var stateWrapper: UIView!
    
    @IBOutlet var stateLabel: UILabel!
    
    @IBOutlet var takePhotoButton: UIButton!
    @IBOutlet var endDateLabel: UILabel!
    @IBOutlet var stateSwitch: UISwitch!
    
    @IBOutlet var textFieldTitle: UITextView!
    @IBOutlet var photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item.title == "" {
            isNewItem = true
            self.stateWrapper.isHidden = true
            self.stateSwitch.isHidden = true
            self.stateLabel.isHidden = true
        }
        
        let saveButton = UIBarButtonItem(title:isNewItem ? "Guardar" : "Editar", style: .plain, target: self, action: #selector(save(sender:)))
        saveButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        
        textFieldTitle.text = item.title
        textFieldTitle.contentInset = UIEdgeInsetsMake(-60, 0, 0, 0)
        photo.loadImage(urlString: item.photoUrl!)
        
        self.textFieldTitle.layer.borderWidth = 1
        self.textFieldTitle.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.textFieldTitle.layer.cornerRadius = 5
        
        self.stateWrapper.layer.borderWidth = 1
        self.stateWrapper.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
        self.stateWrapper.layer.cornerRadius = 5
        
        self.stateLabel.text = item.status
        self.stateSwitch.isOn = item.status == "Finalizada"
        
        self.endDateLabel.layer.borderWidth = 1
        self.endDateLabel.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        self.endDateLabel.layer.cornerRadius = 5
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        tap.delegate = self
        self.endDateLabel.isUserInteractionEnabled = true
        self.endDateLabel.addGestureRecognizer(tap)
        
        self.endDateLabel.text = item.endDate
        
        
        initialPhoto = item.photoUrl!
        // Do any additional setup after loading the view.
    }
    
    func tap(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        self.performSegue(withIdentifier: "toPickingDate", sender: nil)
    }
    
    func selectedDate(date: Date) {
        print(date)
        let newDate = date.string(with: .InternationalFormat)
        self.endDate = newDate
        print(newDate)
        self.endDateLabel.text = Date(string: newDate, formatter: .InternationalFormat)!.string(with: .MonthdayAndYear)
        self.item.endDate = self.endDateLabel.text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationNavController = (segue.destination as? UINavigationController){
            if let datePickerVC = destinationNavController.viewControllers.first as? CalendarOpenViewController{
                datePickerVC.dateToSelect = Date(string: endDateLabel.text!, formatter: .dayMonthAndYear2)
                datePickerVC.dateDelegate = self
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resizeImage(image: UIImage, scale: CGFloat) -> UIImage {
        
        let newWidth = image.size.width * (scale/100)
        let newHeight = image.size.height * (scale/100)
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @IBAction func stateSwitchChanged(_ sender: UISwitch) {
        item.status = item.status == "Pendiente" ? "Finalizada" : "Pendiente"
        store.dispatch(UpdateToDoListItemAction(item:item))
    }
    
    func save(sender: UIBarButtonItem){
        
        let title: String! = textFieldTitle.text
        if title == nil || title.isEmpty{
            service.ANIMATIONS.shakeTextField(txt: textFieldTitle)
            self.view.makeToast("Agrega un título", duration: 1.0, position: CGPoint(x: 200, y: 150))
            return
        }
        
        self.item.title = title
        
        let photoName = NSUUID().uuidString
        //        let user = service.USER_SERVICE.users[0]
        var photoUrl:String = initialPhoto
        
        if tookPhoto {
            photo?.image = resizeImage(image: (photo?.image!)!, scale: 50)
            let uploadData = UIImagePNGRepresentation((photo?.image)!)
            Constants.FirStorage.STORAGEREF.child("users/\(service.USER_SERVICE.users[0].id!)").child("images/\(photoName).png").put(uploadData!, metadata: nil){ metadata, error in
                if error != nil{
                    print(error.debugDescription)
                }else{
                    if let downloadUrl = metadata?.downloadURL()?.absoluteString{
                        StorageService.Instance().save(url: downloadUrl, data: uploadData)
                        photoUrl = downloadUrl
                        self.item.photoUrl = photoUrl
                        if self.isNewItem {
                            store.dispatch(InsertToDoListItemAction(item:self.item))
                        } else {
                            store.dispatch(UpdateToDoListItemAction(item:self.item))
                        }
                    }
                }
            }
        }else{
            if self.isNewItem {
                store.dispatch(InsertToDoListItemAction(item:self.item))
            } else {
                store.dispatch(UpdateToDoListItemAction(item:self.item))
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        photo?.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        tookPhoto = true
    }
    
    @IBAction func changeStatus(_ sender: Any) {
        var currentItem = self.item
        
        if self.stateSwitch.isOn {
            currentItem.status = "Finalizada"
        } else {
            currentItem.status = "Pendiente"
        }
        store.dispatch(UpdateToDoListItemAction(item:currentItem))
    }

    @IBAction func takePhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "Imagen de la tarea", message: "¿Cómo quiere elegir la imagen?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camara", style: .default , handler: { (action) in
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
        alert.modalPresentationStyle = UIModalPresentationStyle.currentContext
        
        present(alert, animated: true) {
            
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

extension EditItemViewController :  UIImagePickerControllerDelegate  {
    
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

extension EditItemViewController: StoreSubscriber{
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        store.subscribe(self){
            state in state.ToDoListState
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.state.ToDoListState.status = .none
        store.unsubscribe(self)
    }
    
    func toggleToDoState(message: String) -> Void {
        // No sé por qué ocupo mostrar un Toast primero, si no lo hago hace doble popViewController
        // y no hay mucho tiempo para andar viendo por qué. Por eso lo escondo en la posición 3000:110
        self.view.makeToast(message, duration: 0.01, position: CGPoint(x: 3000.0, y: 110.0), title: "Mensaje:", image: nil, style: nil) { bool in
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func newState(state: ToDoListState){
        switch state.status {
        case .failed:
            self.view.makeToast("Ocurrio un error, intente de nuevo")
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            self.view.hideToastActivity()
            toggleToDoState(message: "Tarea añadida")
            break
        default: break
        }
    }
}

