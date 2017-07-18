//
//  AddAlbumViewController.swift
//  familyOffice
//
//  Created by Enrique Moya on 29/06/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift
import ReSwift

class AddAlbumViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,StoreSubscriber {
    
    let picker = UIImagePickerController()
    let path: String = "album/" + service.GALLERY_SERVICE.refUserFamily!
    var reference: FIRDatabaseReference = FIRDatabaseReference()
    var chosenImage: UIImage? = nil
    var albums: [Album] = []

    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var imgSelected: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.reference = Constants.FirDatabase.REF.child(self.path).childByAutoId()
        
        self.picker.sourceType = .photoLibrary
        self.picker.delegate = self
        self.picker.allowsEditing = true
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Guardar", style: .done, target: self, action: #selector(createAlbum))
    }
    
    func back() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func createAlbum() -> Void {
        guard self.txtTitle.text != "" else{
            self.view.makeToast("Agrega un título", duration: 1.0, position: CGPoint(x: 200, y: 150))
            return
        }
        let album:Album = Album.init(id: self.reference.key, cover: "", title: txtTitle.text!, images: [])
        let data = NSDictionary(dictionary:  [
            "album": album,
            "reference": "\(self.path)/\(self.reference.key)",
            "reference-img": "albums/\(self.reference.key)/\(Constants.FirDatabase.REF.childByAutoId().key).png",
            "file": imgSelected.image ?? nil
            ])
        store.dispatch(InsertGalleryAction(album: data))
    }
    
    
    
    
    
    @IBAction func chooseImage(_ sender: Any) {
        self.present(self.picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imgSelected.image = info[UIImagePickerControllerEditedImage] as? UIImage
        dismiss(animated: true, completion: nil)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
extension AddAlbumViewController{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        store.subscribe(self){
            state in
            state.GalleryState
        }
        store.state.GalleryState.status = .none
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.state.GalleryState.status = .none
        store.unsubscribe(self)
    }
    func toggleGalleryState(message: String) -> Void {
        self.view.makeToast(message, duration: 0.5, position: CGPoint(x: 110.0, y: 110.0), title: "Mensaje:", image: nil, style: nil, completion: {bool in
            _ = self.navigationController?.popViewController(animated: true)
        })
    }
    func newState(state: GalleryState) {
        switch state.status{
        case .failed:
            self.view.hideToastActivity()
            self.view.makeToast("Ocurrio un error, intente más tarde.")
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .Finished(let messsage as String):
            self.view.hideToastActivity()
            self.toggleGalleryState(message: messsage)
            break
        default:
            self.view.hideToastActivity()
            break;
            
        }
    }
}
