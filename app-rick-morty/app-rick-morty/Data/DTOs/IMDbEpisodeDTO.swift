//
//  IMDbEpisodeDTO.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 28/5/26.
//

import Foundation
import UIKit

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
    
    func toDomain(image: UIImage?) -> IMDbEpisode {
        IMDbEpisode(id: id, title: primaryTitle, image: image, synopsis: plot, rating: rating.aggregateRating, voteCount: rating.voteCount, season: seasonNumber, episodeNumber: episodeNumber)
    }
}

struct IMDbImageDTO: Decodable {
    let url: String
}

struct IMDbRatingDTO: Decodable {
    let aggregateRating: Double
    let voteCount: Int
}
