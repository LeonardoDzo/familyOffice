//
//  PDFViewController.swift
//  familyOffice
//
//  Created by Developer on 8/17/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class PDFViewController: UIViewController {
    var url: String!

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFromUrl()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFromUrl(){
        let url =  NSURL(string:self.url)
        
        self.webView.loadRequest(NSURLRequest(url: url! as URL) as URLRequest)
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
