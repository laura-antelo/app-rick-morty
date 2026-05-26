//
//  FavoriteRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 21/5/26.
//

import Foundation

protocol FavoriteRepository {
    func getFavorites(type: FavoriteType) -> [Favorite]
    func isFavorite(_ favorite: Favorite) -> Bool
    func toggleFavorite(_ favorite: Favorite) -> Bool
}

final class DefaultFavoriteRepository: FavoriteRepository {
    
    private let userDefaults: UserDefaults
    private let favoritesKey = "favorites"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func getFavorites(type: FavoriteType) -> [Favorite] {
        return getAllFavorites().filter { favorite in
            favorite.type == type
        }
    }
    
    func isFavorite(_ favorite: Favorite) -> Bool {
        return getAllFavorites().contains { storedFavorite in
            storedFavorite.id == favorite.id && storedFavorite.type == favorite.type
        }
    }
    
    func toggleFavorite(_ favorite: Favorite) -> Bool {
        var favorites = getAllFavorites()
        
        if let index = favorites.firstIndex(where: {
            $0.id == favorite.id && $0.type == favorite.type
        }) {
            favorites.remove(at: index)
            save(favorites)
            return false
        }
        
        favorites.append(favorite)
        save(favorites)
        return true
    }
    
    private func getAllFavorites() -> [Favorite] {
        guard let data = userDefaults.data(forKey: favoritesKey) else {
            return []
        }
        
        return (try? JSONDecoder().decode([Favorite].self, from: data)) ?? []
    }
    
    private func save(_ favorites: [Favorite]) {
        guard let data = try? JSONEncoder().encode(favorites) else {
            return
        }
        
        userDefaults.set(data, forKey: favoritesKey)
    }
    
    
}
