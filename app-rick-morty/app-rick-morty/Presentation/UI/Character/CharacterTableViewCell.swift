//
//  CharacterTableViewCell.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

class CharacterTableViewCell: UITableViewCell {

    @IBOutlet private weak var characterImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        characterImageView.image = UIImage(systemName: "person.crop.square")
    }
    
    func configure(with character: Character) {
        nameLabel.text = character.name
        characterImageView.image = character.image
    }
    
    /*
    func configure(characterId: Int){
        nameLabel.text = "Personaje \(characterId)"
        characterImageView.image = UIImage(systemName: "person.crop.square")
    }
     */
    
}
