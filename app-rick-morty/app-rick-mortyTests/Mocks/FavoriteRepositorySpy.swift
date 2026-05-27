//
//  FavoriteRepositorySpy.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 27/5/26.
//

import Combine
@testable import app_rick_morty

final class FavoriteRepositorySpy: FavoriteRepository {
    var receivedType: FavoriteType?
    var receivedFavorite: Favorite?
    
    var favorites: [Favorite] = []
    
    func getFavorites(type: FavoriteType) -> [Favorite] {
        receivedType = type
        
        return favorites.filter { favorite in
            favorite.type == type
        }
    }
    
    func isFavorite(_ favorite: Favorite) -> Bool {
        receivedFavorite = favorite
        
        return favorites.contains { storedFavorite in
            storedFavorite.id == favorite.id && storedFavorite.type == favorite.type
        }
    }
    
    func toggleFavorite(_ favorite: Favorite) -> Bool {
        receivedFavorite = favorite
        
        if let index = favorites.firstIndex(where: {
            $0.id == favorite.id && $0.type == favorite.type
        }) {
            favorites.remove(at: index)
            return false
        }
        
        favorites.append(favorite)
        return true
    }
}
