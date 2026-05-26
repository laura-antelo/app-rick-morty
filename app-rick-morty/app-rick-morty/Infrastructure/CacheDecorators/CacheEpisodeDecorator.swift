//
//  CacheEpisodeDecorator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 26/5/26.
//


import Foundation
import UIKit
import Combine

final class CacheEpisodeDecorator: EpisodeRepository {
    
    private let decoratedRepository: EpisodeRepository
    private let cache: DiskCache
    
    init(decoratedRepository: EpisodeRepository, cache: DiskCache = .shared) {
        self.decoratedRepository = decoratedRepository
        self.cache = cache
    }
    
    func getEpisodes(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Episode>, any Error> {
        let cachedKey = Self.listCacheKey(page: page, name: name)
        
        if let cachedResult = cache.load(CachedPaginatedResult<CachedEpisode>.self, forKey: cachedKey) {
            let result = PaginatedResult(items: cachedResult.items.map { $0.toDomain() }, hasNextPage: cachedResult.hasNextPage)
            
            return Just(result)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return decoratedRepository.getEpisodes(page: page, name: name)
            .handleEvents(receiveOutput: { [cache] result in
                let cachedEpisodes = result.items.map { CachedEpisode(episode: $0) }
                
                let cachedResult = CachedPaginatedResult(items: cachedEpisodes, hasNextPage: result.hasNextPage)
                
                cache.save(cachedResult, forKey: cachedKey)
                
                cachedEpisodes.forEach { cachedEpisode in
                    cache.save(cachedEpisode, forKey: Self.detailCacheKey(id: cachedEpisode.id))
                }
            })
            .eraseToAnyPublisher()
    }
    
    func getEpisodeDetail(id: Int) -> AnyPublisher<Episode, Error> {
        let cachedKey = Self.detailCacheKey(id: id)
        
        if let cachedEpisode = cache.load(CachedEpisode.self, forKey: cachedKey) {
            return Just(cachedEpisode.toDomain())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return decoratedRepository.getEpisodeDetail(id: id)
            .handleEvents(receiveOutput: { [cache] episode in
                cache.save(CachedEpisode(episode: episode), forKey: cachedKey)
            })
            .eraseToAnyPublisher()
    }
    
    private static func listCacheKey(page: Int?, name: String?) -> String {
        let pageValue = page ?? 1
        let nameValue = cleanedName(name) ?? "all"
        
        return "episodes_list_page_\(pageValue)_name_\(nameValue)"
    }
    
    private static func cleanedName(_ name: String?) -> String? {
        let cleanedName = name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        return cleanedName?.isEmpty == false ? cleanedName : nil
    }
    
    private static func detailCacheKey(id: Int) -> String {
        return "episode_detail_\(id)"
    }
}

private struct CachedEpisode: Codable {
    let id: Int
    let name: String
    let airDate: String
    let code: String
    let charactersIds: [Int]
    
    init(episode: Episode) {
        self.id = episode.id
        self.name = episode.name
        self.airDate = episode.airDate
        self.code = episode.code
        self.charactersIds = episode.charactersIds
    }
    
    func toDomain() -> Episode {
        return Episode(id: id, name: name, airDate: airDate, code: code, charactersIds: charactersIds)
    }
}
