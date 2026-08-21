//
//  SearchTableViewCell.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var favoriteFilterButton: UIButton!
    
    private var onTextChanged: ((String) -> Void)?
    private var onFavoriteFilterChanged: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        searchBar.delegate = self
        searchBar.placeholder = String(localized: "search.placeholder")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        onTextChanged = nil
        onFavoriteFilterChanged = nil
    }
    
    func configure(text: String, isFavoriteFilterActive: Bool, onTextChanged: @escaping (String) -> Void, onFavoriteFilterChanged: @escaping () -> Void ){
        searchBar.text = text
        self.onTextChanged = onTextChanged
        self.onFavoriteFilterChanged = onFavoriteFilterChanged
        updateFavoriteFilterButton(isActive: isFavoriteFilterActive)
    }
    
    private func updateFavoriteFilterButton(isActive: Bool) {
        let imageName = isActive ? "heart.fill" : "heart"
        
        favoriteFilterButton.setTitle("", for: .normal)
        favoriteFilterButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction private func didTapFavoriteFilterButton() {
        onFavoriteFilterChanged?()
    }
}

extension SearchTableViewCell: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        onTextChanged?(searchText)
    }
}
