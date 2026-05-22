//
//  IsFavoriteUseCase.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 22/5/26.
//

import Foundation

protocol IsFavoriteUseCase {
    func execute(_ favorite: Favorite) -> Bool
}

final class DefaultIsFavoriteUseCase: IsFavoriteUseCase {
    private let repository: FavoriteRepository
    
    init(repository: FavoriteRepository) {
        self.repositor.repository = repository
    }
    
    func execute(_ favorite: Favorite) -> Bool {
        repository.isFavorite(favorite)
    }
}
