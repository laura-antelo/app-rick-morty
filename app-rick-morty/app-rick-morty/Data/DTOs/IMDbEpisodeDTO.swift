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
    
    /*
    enum CodingKeys: String, CodingKey {
        case episodes
        case titles
    }
    
    init(from decoder: Decoder) throws {
        if let singleValueContainer = try? decoder.singleValueContainer(),
            let episodes = try? singleValueContainer.decode([IMDbEpisodeDTO].self) {
            self.episodes = episodes
            return
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.episodes = (try? container.decodeIfPresent([IMDbEpisodeDTO].self, forKey: .episodes)) ?? (try? container.decodeIfPresent([IMDbEpisodeDTO].self, forKey: .titles)) ?? []
    }*/
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
