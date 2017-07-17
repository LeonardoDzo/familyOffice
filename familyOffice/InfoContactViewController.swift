//
//  InfoContactViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 11/07/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import MessageUI

class InfoContactViewController: UIViewController, ContactBindible, UITabBarDelegate, MFMessageComposeViewControllerDelegate {
    var contact: Contact!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var jobLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tabbar: UITabBar!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var webpage: UILabel!
    @IBOutlet weak var dataView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.edit))
        self.navigationItem.rightBarButtonItem = editButton
        self.navigationItem.title = "Info"
        tabbar.delegate = self
        tabbar.layer.cornerRadius = 12
        headerView.layer.cornerRadius = 12
        dataView.layer.cornerRadius = 12
        // Do any additional setup after loading the view.
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
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        switch item.tag {
        case 0:
            guard let number = URL(string: "tel://" + contact.phone!) else { return }
            UIApplication.shared.open(number)
            break
        case 1:
            sendSMSText(phoneNumber: contact.phone!)
            break
        default:
            break
        }
    
    }
    
    func edit() -> Void {
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! addContactTableViewController
        vc.bind(contact: contact)
    }
    

}
