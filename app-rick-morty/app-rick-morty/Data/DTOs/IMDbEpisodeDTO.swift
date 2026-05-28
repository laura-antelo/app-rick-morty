//
//  IMDbEpisodeDTO.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 28/5/26.
//

import Foundation

struct IMDbEpisodeResponseDTO: Decodable {
    let episodes: [IMDbEpisodeDTO]
}

struct IMDbEpisodeDTO: Decodable {
    let id: String
    let primaryTitle: String
    let primaryImage: IMDbImageDTO
    let plot: String
    let rating: IMDbRatingDTO
    let seasonNumber: Int
    let episodeNumber: Int
}

struct IMDbImageDTO: Decodable {
    let url: String
}

struct IMDbRatingDTO: Decodable {
    let aggregateRating: Double
    let voteCount: Int
}
