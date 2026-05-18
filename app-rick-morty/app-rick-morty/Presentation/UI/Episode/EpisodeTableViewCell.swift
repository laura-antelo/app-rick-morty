//
//  EpisodeTableViewCell.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

class EpisodeTableViewCell: UITableViewCell {

    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with episode: Episode) {
        nameLabel.text = episode.name
        descriptionLabel.text = "\(episode.code) - \(episode.airDate)"
    }
    
    func configure(episodeId: Int){
        nameLabel.text = "Episodio: \(episodeId)"
        descriptionLabel.text = ""
    }
}
