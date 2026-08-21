//
//  TranslatedLocationRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 3/6/26.
//

import Foundation
import Combine

final class TranslatedLocationRepository: LocationRepository {
    
    private let decoratedRepository: LocationRepository
    private let translationRepository: TranslationRepository
    private let languageProvider: AppLanguageProvider
    
    init(decoratedRepository: LocationRepository, translationRepository: TranslationRepository, languageProvider: AppLanguageProvider) {
        self.decoratedRepository = decoratedRepository
        self.translationRepository = translationRepository
        self.languageProvider = languageProvider
    }
    
    func getLocations(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Location>, Error> {
        decoratedRepository.getLocations(page: page, name: name)
            .flatMap { [translationRepository, languageProvider] result -> AnyPublisher<PaginatedResult<Location>, Error> in
                Self.translate(locations: result.items, translationRepository: translationRepository, targetLanguage: languageProvider.currentLanguage)
                    .map { translatedLocations in
                        PaginatedResult(items: translatedLocations, hasNextPage: result.hasNextPage)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getLocationDetail(id: Int) -> AnyPublisher<Location, Error> {
        decoratedRepository.getLocationDetail(id: id)
            .flatMap{ [translationRepository, languageProvider] location -> AnyPublisher<Location, Error> in
                Self.translate(location: location, translationRepository: translationRepository, targetLanguage: languageProvider.currentLanguage)
            }
            .eraseToAnyPublisher()
    }
    
    private static func translate(locations: [Location], translationRepository: TranslationRepository, targetLanguage: AppLanguage) -> AnyPublisher<[Location], Error> {
        guard targetLanguage != .english, !locations.isEmpty else {
            return Just(locations)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let publishers = locations.map { location in
            translate(location: location, translationRepository: translationRepository, targetLanguage: targetLanguage)
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { $0.sorted { $0.id < $1.id } }
            .eraseToAnyPublisher()
    }
    
    private static func translate(location: Location, translationRepository: TranslationRepository, targetLanguage: AppLanguage) -> AnyPublisher<Location, Error> {
        guard targetLanguage != .english else {
            return Just(location)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let translatedType = translationRepository
            .translate(location.type, from: .english, to: targetLanguage)
            .replaceError(with: location.type)
        
        let translatedDimension = translationRepository
            .translate(location.dimension, from: .english, to: targetLanguage)
            .replaceError(with: location.dimension)
        
        return Publishers.CombineLatest(translatedType, translatedDimension)
            .map { type, dimension in
                Location(
                    id: location.id,
                    name: location.name,
                    type: type,
                    dimension: dimension,
                    residentsIds: location.residentsIds
                )
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
