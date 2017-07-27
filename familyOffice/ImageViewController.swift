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
    var imageView = UIImageView()
    var tempImage : UIImage! = nil
    var user: User!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneButton : UIBarButtonItem = UIBarButtonItem(title: "Guardar", style: UIBarButtonItemStyle.plain, target: self, action:#selector(save(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        scrollView.delegate = self
        imageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
        // Do any additional setup after loadi
    }
   
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self){
            state in
            state.UserState
        }
        user = store.state.UserState.user
       crop()
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    func crop() -> Void {
        scrollView.zoomScale = 1
        
        imageView.contentMode = UIViewContentMode.center
        imageView.frame = CGRect(x: 0, y: 0, width: imageView.image!.size.width, height: (imageView.image?.size.height)!)
       
        scrollView.contentSize = (imageView.image?.size)!
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = minScale
        centerScrollViewContents()
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func save(sender: UIBarButtonItem) -> Void {
        UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.main.scale)
        let offset = scrollView.contentOffset
        
        UIGraphicsGetCurrentContext()?.translateBy(x: -offset.x, y: -offset.y)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let _ = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //Add validations
        if(imageView.image != nil){
            service.UTILITY_SERVICE.disabledView()
            store.dispatch(UpdateUserAction(user: user, img: imageView.image))
        }else{
            alert()
        }

        
    }
    func alert() -> Void {
        let alert = UIAlertController(title: "Error", message: "Agregue una imagen y un nombre", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func centerScrollViewContents(){
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
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
        imageView.frame = contentsFrame
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
