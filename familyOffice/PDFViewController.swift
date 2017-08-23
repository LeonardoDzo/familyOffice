//
//  PDFViewController.swift
//  familyOffice
//
//  Created by Developer on 8/17/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import WebKit

class PDFViewController: UIViewController, WKUIDelegate {
    var url: String!
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        backButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        
        let myURL = URL(string: url!)
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

    
    func back() -> Void {
        _ = navigationController?.popViewController(animated: true)
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
