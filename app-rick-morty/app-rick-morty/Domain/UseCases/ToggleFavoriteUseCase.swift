//
//  ToggleFavoriteUseCase.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 22/5/26.
//

protocol ToggleFavoriteUseCase {
    func execute(_ favorite: Favorite) -> Bool
}

final class DefaultToggleFavoriteUseCase: ToggleFavoriteUseCase {
    private let repository: FavoriteRepository
    
    init(repository: FavoriteRepository) {
        self.repository = repository
    }
    
    func execute(_ favorite: Favorite) -> Bool {
        repository.toggleFavorite(favorite)
    }
}
