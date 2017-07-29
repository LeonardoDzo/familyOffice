//
//  UIImage.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 06/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//
import UIKit
let imageCache = NSCache<AnyObject, AnyObject>()
let imageBWCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImage(urlString: String, filter: String = "") -> Void {
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        //check if image exist in cache
        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) {
            self.image = nil
            self.image = cacheImage as? UIImage
            self.verifyFilter(filter: filter, urlString: urlString)
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            DispatchQueue.main.async {
                    let decompressedData: Data
                    if (data?.isGzipped)! {
                        decompressedData = try! data?.gunzipped() ?? Data()
                    } else {
                        decompressedData = data!
                    }
                    if let downloadImage = UIImage.init(data: decompressedData) {
                        imageCache.setObject(downloadImage, forKey: urlString as AnyObject)
                        self.image = nil
                        self.image = downloadImage
                        
                        self.verifyFilter(filter: filter, urlString: urlString)
                    }
            }
        }).resume()
        
    }
    func verifyFilter(filter: String, urlString: String) -> Void {
        switch filter {
        case "blackwhite":
            self.blackwhite(urlString: urlString)
            break
        default:
            break
        }
    }
    func circleImage() -> Void {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width/2
    }
    func blackwhite(urlString: String) {
        if let cacheImage = imageBWCache.object(forKey: urlString as AnyObject) {
            self.image = cacheImage as? UIImage
        }else if self.image != nil {
            let context = CIContext(options: nil)
            let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
            currentFilter!.setValue(CIImage(image: self.image!), forKey: kCIInputImageKey)
            let output = currentFilter!.outputImage
            let cgimg = context.createCGImage(output!,from: output!.extent)
            let processedImage = UIImage(cgImage: cgimg!)
            self.image = processedImage
            imageBWCache.setObject(processedImage, forKey: urlString as AnyObject)
        }
    }
    
    func profileUser() -> Void {
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
        self.layer.borderWidth = 4.0
        self.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
    }
    

}
class CustomUIImageView: UIImageView {
    var urlString: String?
    private var activityIndicator: UIActivityIndicatorView!
    
    override func loadImage(urlString: String, filter: String = "") -> Void {
        
        guard let url = URL(string: urlString) else {
            return
        }
        showLoading()
        
        self.image = nil
        self.urlString = urlString
        //check if image exist in cache
        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) {
            self.image = cacheImage as? UIImage
            self.verifyFilter(filter: filter, urlString: urlString)
            hideLoading()
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            DispatchQueue.main.async {
                let decompressedData: Data
                if (data?.isGzipped)! {
                    decompressedData = try! data?.gunzipped() ?? Data()
                } else {
                    decompressedData = data!
                }
                if let downloadImage = UIImage.init(data: decompressedData) {
                    imageCache.setObject(downloadImage, forKey: urlString as AnyObject)
                    if urlString == self.urlString{
                        self.image = downloadImage
                        self.hideLoading()
                    }
                    self.verifyFilter(filter: filter, urlString: urlString)
                }
            }
        }).resume()
        
    }
    override func verifyFilter(filter: String, urlString: String) -> Void {
        switch filter {
        case "blackwhite":
            self.blackwhite(urlString: urlString)
            break
        default:
            break
        }
    }
    
    override func blackwhite(urlString: String) {
        if let cacheImage = imageBWCache.object(forKey: urlString as AnyObject) {
            self.image = cacheImage as? UIImage
        }else if self.image != nil {
            let context = CIContext(options: nil)
            let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
            currentFilter!.setValue(CIImage(image: self.image!), forKey: kCIInputImageKey)
            let output = currentFilter!.outputImage
            let cgimg = context.createCGImage(output!,from: output!.extent)
            let processedImage = UIImage(cgImage: cgimg!)
            self.image = processedImage
            imageBWCache.setObject(processedImage, forKey: urlString as AnyObject)
        }
    }
    
    func showLoading() {
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }

    
    func hideLoading() {
        activityIndicator.stopAnimating()
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.lightGray
        return activityIndicator
    }
    
    func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
    
}

extension UIImage{
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in PNG format
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the PNG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    var png: Data? { return UIImagePNGRepresentation(self) }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    func resizeImage()-> UIImage{
        if !(self.size.width * self.scale).isLess(than: CGFloat.init(1280)) || !(self.size.height * self.scale).isLess(than: CGFloat.init(1280)) {
            if self.isLandscape(){
                let newWidth = CGFloat.init(1280)
                let newHeight = self.size.height * (self.porcentSize(maxSize: newWidth)/100)
                UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
                self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
                
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                return newImage!
            }else{
                let newHeight = CGFloat.init(1280)
                let newWidth = self.size.width * (self.porcentSize(maxSize: newHeight)/100)
                UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
                self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
                
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                return newImage!
            }
        }
        return self
    }
    func resizeToSmall()-> UIImage{
        if self.isLandscape(){
            let newWidth = CGFloat.init(50)
            let newHeight = self.size.height * (self.porcentSize(maxSize: newWidth)/100)
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }else{
            let newHeight = CGFloat.init(50)
            let newWidth = self.size.width * (self.porcentSize(maxSize: newHeight)/100)
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }
        
    }
    func resizeToMed()-> UIImage{
        if self.isLandscape(){
            let newWidth = CGFloat.init(150)
            let newHeight = self.size.height * (self.porcentSize(maxSize: newWidth)/100)
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }else{
            let newHeight = CGFloat.init(150)
            let newWidth = self.size.width * (self.porcentSize(maxSize: newHeight)/100)
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }
        
    }
    func resizeToLarge()-> UIImage{
        if self.isLandscape(){
            let newWidth = CGFloat.init(400)
            let newHeight = self.size.height * (self.porcentSize(maxSize: newWidth)/100)
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }else{
            let newHeight = CGFloat.init(400)
            let newWidth = self.size.width * (self.porcentSize(maxSize: newHeight)/100)
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }
        
    }
    internal func porcentSize(maxSize: CGFloat) -> CGFloat {
        if self.isLandscape(){
            let result: CGFloat = (maxSize * 100)/(self.size.width * self.scale)
            return result
        }else{
            let result: CGFloat = (maxSize * 100)/(self.size.height * self.scale)
            return result
        }
    }
    func isLandscape() -> Bool {
        if (self.size.width * self.scale).isLess(than: CGFloat.init(self.size.height * self.scale)){
            return false
        }else{
            return true
        }
    }
}
