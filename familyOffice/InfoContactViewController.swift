//
//  InfoContactViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 11/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import MessageUI
import Toast_Swift
import Contacts
import CoreLocation
import MapKit

class InfoContactViewController: UIViewController, ContactBindible, UITabBarDelegate, MFMessageComposeViewControllerDelegate,UIGestureRecognizerDelegate {
    var contact: Contact!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var jobLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tabbar: UITabBar!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet var webpageBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.edit))
        self.navigationItem.rightBarButtonItem = editButton
        self.navigationItem.title = "Info"
        tabbar.delegate = self
        tabbar.layer.cornerRadius = 12
        headerView.layer.cornerRadius = 12
        dataView.layer.cornerRadius = 12
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        tap.delegate = self
        self.addressLbl.isUserInteractionEnabled = true
        self.addressLbl.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
        //webpageBtn.setTitle(contact.webpage, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        let key = store.state.UserState.user?.familyActive
        if let xcontact = store.state.ContactState.contacts[key!]?.first(where: {$0.id == contact.id}) {
            self.bind(contact: xcontact)
        }else{
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        if (contact.address?.isEmpty)!{
            return
        }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(contact.address!) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else{
                    return
            }
            
            let regionDistance:CLLocationDistance = 100
            let regionSpan = MKCoordinateRegionMakeWithDistance(location.coordinate, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "\(self.contact.name!)"
            mapItem.openInMaps(launchOptions: options)
        }
        
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        switch item.tag {
        case 0:
            guard let number = URL(string: "tel://" + contact.phone!) else { return }
            UIApplication.shared.open(number)
            break
        case 1:
            sendSMSText(phoneNumber: contact.phone!)
            break
        case 2:
            if !(contact.email?.isEmpty)!{
                guard let url = URL(string: "mailto:" + contact.email!) else { return }
                UIApplication.shared.open(url)
            }
            break
        default:
            break
        }
    
    }
    
    
    @IBAction func openPage(_ sender: UIButton) {
        if(!(contact.webpage?.isEmpty)!){
            guard let url = URL(string: "http://\(contact.webpage!)") else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    @objc func edit() -> Void {
        performSegue(withIdentifier: "editSegue", sender: contact)
    }
    func sendSMSText(phoneNumber: String) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = [phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func exportButtonPressed(_ sender: UIButton) {
        let exportedContact = CNMutableContact()
        
        let adress = CNMutablePostalAddress()
        adress.street = self.contact.address!
        let email = CNLabeledValue(label: CNLabelHome, value: self.contact.email! as NSString)
        let webpage = CNLabeledValue(label: CNLabelURLAddressHomePage, value: self.contact.webpage! as NSString)
        
        exportedContact.givenName = self.contact.name
        exportedContact.phoneNumbers = [CNLabeledValue(label:CNLabelPhoneNumberMobile,value:CNPhoneNumber(stringValue: self.contact.phone!))]
        exportedContact.postalAddresses = [CNLabeledValue(label: CNLabelWork, value: adress)]
        exportedContact.emailAddresses = [email]
        exportedContact.urlAddresses = [webpage]
        
        let contactStore = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(exportedContact, toContainerWithIdentifier: nil)
        try! contactStore.execute(saveRequest)
        
        self.view.makeToast("Contacto exportado")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! addContactTableViewController
        vc.bind(contact: contact)
    }
    

}
