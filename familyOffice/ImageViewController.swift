//
//  ImageViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 08/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import ReSwift
class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UIScrollViewDelegate {
    @IBOutlet weak var imageView: UIImageView!
    var user: User!
    var minZoomScale:CGFloat!
    var chooseImg = UIImage()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.plain, target: self, action:#selector(save(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        scrollView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        store.state.UserState.status = .none
        user = store.state.UserState.user
        setImageToCrop(image: chooseImg)
        store.subscribe(self){
            state in
            state.UserState
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    func setImageToCrop(image:UIImage){
        imageView.image = image
        imageViewWidth.constant = image.size.width
        imageViewHeight.constant = image.size.height
        let scaleHeight = scrollView.frame.size.width/image.size.width
        let scaleWidth = scrollView.frame.size.height/image.size.height
        scrollView.minimumZoomScale = max(scaleWidth, scaleHeight)
        scrollView.zoomScale = max(scaleWidth, scaleHeight)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func save(sender: UIBarButtonItem) -> Void {
        let scale:CGFloat = 1/scrollView.zoomScale
        let x:CGFloat = scrollView.contentOffset.x * scale
        let y:CGFloat = scrollView.contentOffset.y * scale
        let width:CGFloat = scrollView.frame.size.width * scale
        let height:CGFloat = scrollView.frame.size.height * scale
        let croppedCGImage = imageView.image?.cgImage?.cropping(to: CGRect(x: x, y: y, width: width, height: height))
        let croppedImage = UIImage(cgImage: croppedCGImage!)
        
        service.UTILITY_SERVICE.disabledView()
        store.dispatch(UpdateUserAction(user: user, img: croppedImage))
        
    }
    func alert() -> Void {
        let alert = UIAlertController(title: "Error", message: "Agregue una imagen y un nombre", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    
}
extension ImageViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = UserState
    
    func newState(state: UserState) {
        self.view.hideToastActivity()
        switch state.status {
        case .loading:
            self.view.makeToastActivity(.center)
            break
        case .finished:
            service.UTILITY_SERVICE.enabledView()
            self.navigationController?.popViewController(animated: true)
            break
        case .failed:
            alert()
            break
        default:
            break
        }
    }
}
