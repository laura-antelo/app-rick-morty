//
//  CacheIMDbEpisodeDecorator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 29/5/26.
//

import Foundation
import UIKit
import Combine

final class CacheIMDbEpisodeDecorator: IMDbEpisodeRepository {
    private let decoratedRepository: IMDbEpisodeRepository
    private let cache: DiskCache
    
    init(decoratedRepository: IMDbEpisodeRepository, cache: DiskCache = .shared) {
        self.decoratedRepository = decoratedRepository
        self.cache = cache
    }
    
    func getEpisodes(season: Int) -> AnyPublisher<[IMDbEpisode], Error>{
        let cachedKey = "imdb_episodes_season_\(season)"
        
        if let cachedEpisodes = cache.load([CachedIMDbEpisode].self, forKey: cachedKey) {
            return Just(cachedEpisodes.map { $0.toDomain() })
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return decoratedRepository.getEpisodes(season: season)
            .handleEvents(receiveOutput: { [cache] episodes in
                let cachedEpisodes = episodes.map { CachedIMDbEpisode(episode: $0) }
                cache.save(cachedEpisodes, forKey: cachedKey)
            })
            .eraseToAnyPublisher()
    }
}

private struct CachedIMDbEpisode: Codable {
    let id: String
    let title: String
    let imageData: Data?
    let synopsis: String
    let rating: Double
    let voteCount: Int
    let season: Int
    let episodeNumber: Int
    
    init(episode: IMDbEpisode) {
        self.id = episode.id
        self.title = episode.title
        self.imageData = episode.image?.pngData()
        self.synopsis = episode.synopsis
        self.rating = episode.rating
        self.voteCount = episode.voteCount
        self.season = episode.season
        self.episodeNumber = episode.episodeNumber
    }
    
    func toDomain() -> IMDbEpisode {
        let image = imageData.flatMap{ UIImage(data: $0 ) }
        
        return IMDbEpisode(id: id, title: title, image: image, synopsis: synopsis, rating: rating, voteCount: voteCount, season: season, episodeNumber: episodeNumber)
    }
}
