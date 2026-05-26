//
//  Favorite.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 21/5/26.
//

import Foundation

struct Favorite: Codable, Equatable {
    let id: Int
    let type: FavoriteType
    let name: String
}

enum FavoriteType: String, Codable {
    case character
    case episode
    case location
}
