//
//  Utility.swift
//
//
//  Created by Leonardo Durazo on 05/01/17.
//
//
import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

private var activityIndicatior:UIActivityIndicatorView = UIActivityIndicatorView()

class Utility {
    
    private init(){
    }
    
    public static func Instance() -> Utility {
        return instance
    }
    static let instance : Utility = Utility()
    var state = 0
    
    func gotoView(view:String, context: UIViewController )  {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController : UIViewController = storyboard.instantiateViewController(withIdentifier: view)
        context.present(viewController, animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            //if(size.width > size.height) {
            //newSize = CGSize(width: targetSize.width, height: size.width * targetSize.width / targetSize.height)
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            //newSize = CGSize(width: size.height * targetSize.width / targetSize.height, height: targetSize.height)
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //radious corner
    func radiousCorner(obj: AnyObject){
        obj.layer.cornerRadius = obj.frame.size.width/2
    }
    
    func disabledView(){
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    
    func enabledView(){
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func loading(view:UIView){
        //loading
        activityIndicatior.center = view.center
        activityIndicatior.hidesWhenStopped = true
        activityIndicatior.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicatior)
        activityIndicatior.startAnimating()
    }
    
    func stopLoading(view: UIView){
        
        activityIndicatior.stopAnimating()
    }
    func getDate() -> Double {
        let date = NSDate().timeIntervalSince1970
        return date
    }
    
    func getDate(date: Double) -> String{
        let xdate = NSDate(timeIntervalSince1970: abs(date)/1000)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd MM yyyy HH:mm"
        return dayTimePeriodFormatter.string(from: xdate as Date)
    }
    
    func clearObservers(){
        Constants.FirDatabase.REF.removeAllObservers()
        Constants.FirDatabase.REF_USERS.removeAllObservers()
        Constants.FirDatabase.REF_FAMILIES.removeAllObservers()
        Constants.FirDatabase.REF_ACTIVITY.removeAllObservers()
        Constants.FirDatabase.REF_NOTIFICATION.removeAllObservers()
        NotificationCenter.default.removeObserver(notCenter.NOFAMILIES_NOTIFICATION)
    }
    
    func exist(field: String, dictionary:NSDictionary) -> String! {
        if let value = dictionary[field] as?  String {
            return value 
        }else {
            return ""
        }
    }
    func exist(field: String, dictionary:NSDictionary) -> Double! {
        if let value = dictionary[field] {
            return value as! Double
        }else {
            return 0.0
        }
    }
    func exist(field: String, dictionary:NSDictionary) -> Int! {
        if let value = dictionary[field] {
            return value as! Int
        }else {
            return 0
        }
    }
    func exist(field: String, dictionary:NSDictionary) -> Bool! {
        if let value = dictionary[field] {
            return value as! Bool
        }else {
            return nil
        }
    }
    func exist(field: String, dictionary:NSDictionary ) -> [String]! {
        if let value = dictionary[field] {
            let v = value as! NSDictionary
            return v.allKeys as! [String]
        }else {
            return []
        }
    }
    func existData(field: String, dictionary: NSDictionary) -> Data? {
        if let value = dictionary[field] {
            return (value as! Data)
        }else {
            return UIImagePNGRepresentation(#imageLiteral(resourceName: "Profile2") )
        }
    }
    func existArray(field: String, dictionary:NSDictionary) -> [Any] {
        if let value = dictionary[field] {
            return value as! Array<Any>
        }else {
            return []
        }
    }
    func exist(field: String, dictionary:NSDictionary) -> NSDictionary {
        guard let value = dictionary[field] as? NSDictionary else {
            return [:]
        }
        return value
    }
    
    func exist(field: String, dictionary:NSDictionary) -> [String:Bool] {
        guard let value = dictionary[field] as? NSDictionary else {
            return [:]
        }
        return value as! [String : Bool]
    }
    
    func exist(field: String, dictionary:NSDictionary) -> [String:Int] {
        guard let value = dictionary[field] as? NSDictionary else {
            return [:]
        }
        return value as! [String : Int]
    }
    
    func toDictionary(array: [String]!) -> NSDictionary {
        let dictionary: NSDictionary = {
            var d : [String: Bool] = [:]
            for item in array{
                d[item] = true
            }
            return d as NSDictionary
        }()
        return dictionary
    }
   
    func moveTextField(textField: UITextField, moveDistance: Int, up: Bool, context: UIViewController){
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance: -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        context.view.frame = context.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
}
