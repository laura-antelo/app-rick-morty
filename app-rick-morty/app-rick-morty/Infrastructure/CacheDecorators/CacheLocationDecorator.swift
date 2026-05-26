//
//  CacheLocationDecorator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 26/5/26.
//

import Foundation
import UIKit
import Combine

final class CacheLocationDecorator: LocationRepository {
    
    private let decoratedRepository: LocationRepository
    private let cache: DiskCache
    
    init(decoratedRepository: LocationRepository, cache: DiskCache = .shared) {
        self.decoratedRepository = decoratedRepository
        self.cache = cache
    }
    
    func getLocations(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Location>, any Error> {
        let cachedKey = Self.listCacheKey(page: page, name: name)
        
        if let cachedResult = cache.load(CachedPaginatedResult<CachedLocation>.self, forKey: cachedKey) {
            let result = PaginatedResult(items: cachedResult.items.map { $0.toDomain() }, hasNextPage: cachedResult.hasNextPage)
            
            return Just(result)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return decoratedRepository.getLocations(page: page, name: name)
            .handleEvents(receiveOutput: { [cache] result in
                let cachedLocations = result.items.map { CachedLocation(location: $0) }
                
                let cachedResult = CachedPaginatedResult(items: cachedLocations, hasNextPage: result.hasNextPage)
                
                cache.save(cachedResult, forKey: cachedKey)
                
                cachedLocations.forEach { cachedLocation in
                    cache.save(cachedLocation, forKey: Self.detailCacheKey(id: cachedLocation.id))
                }
            })
            .eraseToAnyPublisher()
    }
    
    func getLocationDetail(id: Int) -> AnyPublisher<Location, Error> {
        let cachedKey = Self.detailCacheKey(id: id)
        
        if let cachedLocation = cache.load(CachedLocation.self, forKey: cachedKey) {
            return Just(cachedLocation.toDomain())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return decoratedRepository.getLocationDetail(id: id)
            .handleEvents(receiveOutput: { [cache] location in
                cache.save(CachedLocation(location: location), forKey: cachedKey)
            })
            .eraseToAnyPublisher()
    }
    
    private static func listCacheKey(page: Int?, name: String?) -> String {
        let pageValue = page ?? 1
        let nameValue = cleanedName(name) ?? "all"
        
        return "locations_list_page_\(pageValue)_name_\(nameValue)"
    }
    
    private static func cleanedName(_ name: String?) -> String? {
        let cleanedName = name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        return cleanedName?.isEmpty == false ? cleanedName : nil
    }
    
    private static func detailCacheKey(id: Int) -> String {
        return "location_detail_\(id)"
    }
}

private struct CachedLocation: Codable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residentsIds: [Int]
    
    init(location: Location) {
        self.id = location.id
        self.name = location.name
        self.type = location.type
        self.dimension = location.dimension
        self.residentsIds = location.residentsIds
    }
    
    func toDomain() -> Location {
        return Location(id: id, name: name, type: type, dimension: dimension, residentsIds: residentsIds)
    }
}
