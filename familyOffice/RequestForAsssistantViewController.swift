//
//  RequestForAsssistantViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 22/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
class RequestForAsssistantViewController: UIViewController {
    var v = RequestAssistantMainView()
    var handle : UInt!
    override func loadView() { view = v }
    override func viewDidLoad() {
        super.viewDidLoad()
        on("INJECTION_BUNDLE_NOTIFICATION") {
            self.v = RequestAssistantMainView()
            self.view = self.v
        }
        self.setupBack()
        // Do any additional setup after loading the view.
        getAssistants()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAssistants() -> Void {
        handle = Constants.FirDatabase.REF.child("assistants").observe(.childAdded, with: { (snapshot) in
            if snapshot.exists(){
                if let snapshotValue = snapshot.value as? NSDictionary {
                    if let data = snapshotValue.jsonToData() {
                        do {
                            let assistant = try JSONDecoder().decode(AssistantEntity.self, from: data)
                            rManager.save(objs: assistant)
                        }catch let error {
                            print(error.localizedDescription)
                        }
                        
                    }
                }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if handle != nil {
              Constants.FirDatabase.REF.child("assistants").removeObserver(withHandle: handle)
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
