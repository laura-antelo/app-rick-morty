//
//  GetFavoriteUseCase.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 25/5/26.
//

import Foundation
import Combine

protocol GetFavoriteUseCase {
    func execute(_ type: FavoriteType) -> [Favorite]
}

final class DefaultGetFavoriteUseCase: GetFavoriteUseCase {
    private let repository: FavoriteRepository
    
    init(repository: FavoriteRepository) {
        self.repository = repository
    }
    
    func execute(_ type: FavoriteType) -> [Favorite] {
        repository.getFavorites(type: type)
    }
}
