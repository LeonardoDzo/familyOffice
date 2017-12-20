//
//  UITableView.swift
//  familyOffice
//
//  Created by Nan Montaño on 19/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

extension UITableView {
    
    func scrollToBottom(animated: Bool) {
        let lastSection = self.numberOfSections - 1
        guard lastSection >= 0 else { return; }
        let lastRow = self.numberOfRows(inSection: lastSection) - 1
        guard lastRow >= 0 else { return; }
        let indexPath = IndexPath(row: lastRow, section: lastSection)
        self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }
    
}
