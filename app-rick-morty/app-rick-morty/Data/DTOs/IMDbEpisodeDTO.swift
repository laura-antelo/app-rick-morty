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
    let nextPageToken: String?
}

struct IMDbEpisodeDTO: Decodable {
    let id: String
    let title: String
    let primaryImage: IMDbImageDTO
    let plot: String?
    let rating: IMDbRatingDTO?
    let season: String
    let episodeNumber: Int
    
    func toDomain(image: UIImage?) -> IMDbEpisode {
        IMDbEpisode(id: id, title: title, image: image, synopsis: plot ?? "Sin sinopsis", rating: rating?.aggregateRating ?? 0, voteCount: rating?.voteCount ?? 0, season: Int(season) ?? 0, episodeNumber: episodeNumber)
    }
}

struct IMDbImageDTO: Decodable {
    let url: String
}

struct IMDbRatingDTO: Decodable {
    let aggregateRating: Double
    let voteCount: Int
}
