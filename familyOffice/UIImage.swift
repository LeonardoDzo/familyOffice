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


