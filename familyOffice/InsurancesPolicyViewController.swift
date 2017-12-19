//
//  InsurancesPolicyViewController.swift
//  familyOffice
//
//  Created by Jesús Ernesto Jaramillo Salazat on 12/18/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import WebKit

class InsurancesPolicyViewController: UIViewController, WKUIDelegate {

    var insurance: Insurance!
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBack()
        
        let myURL = URL(string: insurance.downloadUrl!)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
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

}
