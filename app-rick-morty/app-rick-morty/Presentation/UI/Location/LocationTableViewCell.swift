//
//  LocationTableViewCell.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with location: Location) {
        nameLabel.text = location.name
        descriptionLabel.text = "\(location.type) - \(location.dimension)"
    }
    
    func configure(with reference: LocationReference, title: String){
        nameLabel.text = "\(title): \(reference.name)"
        descriptionLabel.text = ""
    }
    
}
