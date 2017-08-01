//
//  EventTableViewCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 30/03/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell, EventBindable {
    var event: Event!
    weak var delegate : CalendarViewController!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //bar.backgroundColor = .random()
    }
    //Binding DateModelBindable
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    var remimberLabel: UILabel!
    
    @IBOutlet weak var dateSelected: UILabel!
    @IBOutlet weak var bar: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    func tapFunction(sender:UITapGestureRecognizer) {
        delegate.gotoView(event: event!, segue: "showEventSegue")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func  setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    
    }
    
   
}
