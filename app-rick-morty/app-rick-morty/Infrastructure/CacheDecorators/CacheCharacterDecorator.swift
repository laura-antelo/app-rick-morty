//
//  CacheCharacterDecorator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 26/5/26.
//

import Foundation
import UIKit
import Combine

final class CacheCharacterDecorator: CharacterRepository {
    
    private let decoratedRepository: CharacterRepository
    private let cache: DiskCache
    
    init(decoratedRepository: CharacterRepository, cache: DiskCache = .shared) {
        self.decoratedRepository = decoratedRepository
        self.cache = cache
    }
    
    func getCharacters(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Character>, any Error> {
        let cachedKey = Self.listCacheKey(page: page, name: name)
        
        if let cachedResult = cache.load(CachedPaginatedResult<CachedCharacter>.self, forKey: cachedKey) {
            let result = PaginatedResult(items: cachedResult.items.map { $0.toDomain() }, hasNextPage: cachedResult.hasNextPage)
            
            return Just(result)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return decoratedRepository.getCharacters(page: page, name: name)
            .handleEvents(receiveOutput: { [cache] result in
                let cachedCharacters = result.items.map { CachedCharacter(character: $0) }
                
                let cachedResult = CachedPaginatedResult(items: cachedCharacters, hasNextPage: result.hasNextPage)
                
                cache.save(cachedResult, forKey: cachedKey)
                
                cachedCharacters.forEach { cachedCharacter in
                    cache.save(cachedCharacter, forKey: Self.detailCacheKey(id: cachedCharacter.id))
                }
            })
            .eraseToAnyPublisher()
    }
    
    func getCharacterDetail(id: Int) -> AnyPublisher<Character, Error> {
        let cachedKey = Self.detailCacheKey(id: id)
        
        if let cachedCharacter = cache.load(CachedCharacter.self, forKey: cachedKey) {
            return Just(cachedCharacter.toDomain())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return decoratedRepository.getCharacterDetail(id: id)
            .handleEvents(receiveOutput: { [cache] character in
                cache.save(CachedCharacter(character: character), forKey: cachedKey)
            })
            .eraseToAnyPublisher()
    }
    
    private static func listCacheKey(page: Int?, name: String?) -> String {
        let pageValue = page ?? 1
        let nameValue = cleanedName(name) ?? "all"
        
        return "characters_list_page_\(pageValue)_name_\(nameValue)"
    }
    
    private static func cleanedName(_ name: String?) -> String? {
        let cleanedName = name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        return cleanedName?.isEmpty == false ? cleanedName : nil
    }
    
    private static func detailCacheKey(id: Int) -> String {
        return "character_detail_\(id)"
    }
}

private struct CachedCharacter: Codable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let originId: Int?
    let originName: String
    let locationId: Int?
    let locationName: String
    let imageURLString: String?
    let episodeIds: [Int]
    let imageData: Data?
    
    init(character: Character) {
        self.id = character.id
        self.name = character.name
        self.status = character.status.rawValue
        self.species = character.species
        self.type = character.type
        self.gender = character.gender
        self.originId = character.origin.id
        self.originName = character.origin.name
        self.locationId = character.location.id
        self.locationName = character.location.name
        self.imageURLString = character.imageURL?.absoluteString
        self.episodeIds = character.episodeIds
        self.imageData = character.image?.pngData()
    }
    
    func toDomain() -> Character {
        let image: UIImage?
        
        if let imageData = imageData {
            image = UIImage(data: imageData)
        } else {
            image = nil
        }
        
        return Character(id: id, name: name, status: CharacterStatus(rawValue: status) ?? .unknown, species: species, type: type, gender: gender, origin: LocationReference(id: originId, name: originName), location: LocationReference(id: locationId, name: locationName), imageURL: URL(string: imageURLString ?? ""), episodeIds: episodeIds, image: image)
    }
}
