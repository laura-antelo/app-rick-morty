//
//  EpisodeTableViewCell.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

class EpisodeTableViewCell: UITableViewCell {

    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var episodeImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        codeLabel.text = nil
        episodeImageView.image = UIImage(systemName: "tv")
        descriptionLabel.text = nil
    }

    func configure(with episode: Episode) {
        nameLabel.text = episode.name
        codeLabel.text = episode.code
        episodeImageView.image = episode.image ?? UIImage(systemName: "tv")
        descriptionLabel.text = episode.synopsis.isEmpty ? String(localized: "episode.synopsis.empty") : episode.synopsis
    }
}
