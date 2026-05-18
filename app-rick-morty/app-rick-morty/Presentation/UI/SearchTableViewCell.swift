//
//  SearchTableViewCell.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet private weak var searchBar: UISearchBar!
    
    private var onTextChanged: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        onTextChanged = nil
    }
    
    func configure(text: String, onTextChanged: @escaping (String) -> Void){
        searchBar.text = text
        self.onTextChanged = onTextChanged
    }
}

extension SearchTableViewCell: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        onTextChanged?(searchText)
    }
}
