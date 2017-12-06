//
//  PDFViewController.swift
//  familyOffice
//
//  Created by Developer on 8/17/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import WebKit
import Toast_Swift

class PDFViewController: UIViewController, WKUIDelegate {
    var file: SafeBoxFile!
    var previewAct:[UIPreviewAction] = []
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        backButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        
        let myURL = URL(string: file.downloadUrl!)
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

    
    var previewActions: [UIPreviewActionItem]{
        return self.previewAct
//        return [
//            UIPreviewAction(title: "Mover", style: .default, handler: { (UIPreviewAction, UIViewController) in
//                print(UIViewController)
//            }),
//            UIPreviewAction(title: "Eliminar", style: .destructive , handler: { (UIPreviewAction, UIViewController) in
//                store.dispatch(DeleteSafeBoxFileAction(item: self.file))
//            })
//        ]
//        
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
