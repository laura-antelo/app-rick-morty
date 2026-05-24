//
//  LoadMoreTableViewCell.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 22/5/26.
//

import UIKit

class LoadMoreTableViewCell: UITableViewCell {

    @IBOutlet private weak var loadMoreButton: UIButton!
    
    private var onTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        onTap = nil
    }
    
    func configure(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }
    
    @IBAction private func loadMoreButtonTapped(_ sender: UIButton) {
        onTap?()
    }
}
