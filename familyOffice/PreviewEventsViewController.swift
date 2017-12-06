//
//  PreviewEventsViewController.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 04/12/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class PreviewEventsViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    
    var contentWith: CGFloat = 0.0
    override func viewDidLoad() {

        
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: self.scrollView.bounds.width*3, height: self.scrollView.bounds.height)
        scrollView.showsHorizontalScrollIndicator = false
        super.viewDidLoad()
        
        for i in 0...2 {
            let preevent = PreviewEvent.instanceFromNib()
            scrollView.addSubview(preevent)
            preevent.frame.size.width = self.view.bounds.width
            preevent.frame.origin.x = self.view.bounds.size.width * CGFloat(i)
        }
      
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension PreviewEventsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(page)
    }
}
extension PreviewEventsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
}
