//
//  AddToDoItemController.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 6/30/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import ReSwift
import ReSwiftRouter

class AddToDoItemController: UIViewController,UINavigationControllerDelegate,UIGestureRecognizerDelegate,DateProtocol {
    var item:ToDoList.ToDoItem!
    var endDate: String!
    var imagePicker: UIImagePickerController!

    @IBOutlet var endDateLbl: UILabel!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var photo: UIImageView?
    
    let user = service.USER_SERVICE.users[0]
    let path: String = "todolist/\(service.USER_SERVICE.users[0].id!)"
    var reference: FIRDatabaseReference = FIRDatabaseReference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        endDateLbl.layer.borderWidth = 1
        endDateLbl.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor
        endDateLbl.layer.cornerRadius = 4
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        tap.delegate = self
        endDateLbl.isUserInteractionEnabled = true
        endDateLbl.addGestureRecognizer(tap)
        let saveButton = UIBarButtonItem(title: "Guardar", style: .plain, target: self, action: #selector(save(sender:)))
        self.navigationItem.rightBarButtonItem = saveButton
        // Do any additional setup after loading the view.
    }
    
    func tap(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        self.performSegue(withIdentifier: "toDatePicker", sender: nil)
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
    
    func selectedDate(date: Date) {
        let newDate = date.string(with: .InternationalFormat)
        self.endDate = newDate
        endDateLbl.text = "  " + newDate != "" ? Date(string: newDate, formatter: .InternationalFormat)!.string(with: .MonthdayAndYear) : "Sin fecha"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationNavController = (segue.destination as? UINavigationController){
            if let datePickerVC = destinationNavController.viewControllers.first as? CalendarOpenViewController{
                datePickerVC.dateToSelect = Date(string: endDateLbl.text!, formatter: .dayMonthAndYear2)
                datePickerVC.dateDelegate = self
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func save(sender: UIBarButtonItem){
        let title: String! = titleTextField.text
        if title == nil || title.isEmpty{
            service.ANIMATIONS.shakeTextField(txt: titleTextField)
            self.view.makeToast("Agrega un título", duration: 1.0, position: CGPoint(x: 200, y: 150))
            return
        }
        
        let photoName = NSUUID().uuidString
//        let user = service.USER_SERVICE.users[0]
        var photoUrl:String = ""
        
        if photo?.image != nil {
            photo?.image = resizeImage(image: (photo?.image!)!, scale: 20)
            let uploadData = UIImagePNGRepresentation((photo?.image)!)
            Constants.FirStorage.STORAGEREF.child("users/\(service.USER_SERVICE.users[0].id!)").child("images/\(photoName).png").put(uploadData!, metadata: nil){ metadata, error in
                if error != nil{
                    print(error.debugDescription)
                }else{
                    if let downloadUrl = metadata?.downloadURL()?.absoluteString{
                        StorageService.Instance().save(url: downloadUrl, data: uploadData)
                        photoUrl = downloadUrl
                        
                        let item = ToDoList.ToDoItem(title: title, photoUrl: photoUrl, status: "Pendiente",endDate:Date(string: self.endDate, formatter: .InternationalFormat)!.string(with: .MonthdayAndYear))
                        store.dispatch(InsertToDoListItemAction(item:item))
                    }
                }
            }
        }else{
            let item = ToDoList.ToDoItem(title: title, photoUrl: "", status: "Pendiente",endDate:Date(string: self.endDate, formatter: .InternationalFormat)!.string(with: .MonthdayAndYear))
            store.dispatch(InsertToDoListItemAction(item:item))
        }
        
        
        
        
//        navigationController!.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        photo?.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
}

extension AddToDoItemController :  UIImagePickerControllerDelegate  {
    
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

extension AddToDoItemController: StoreSubscriber{
    
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
