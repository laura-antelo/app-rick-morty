//
//  TranslatedCharacterRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 3/6/26.
//

import Foundation
import Combine

final class TranslatedCharacterRepository: CharacterRepository {
    
    private let decoratedRepository: CharacterRepository
    private let translationRepository: TranslationRepository
    private let languageProvider: AppLanguageProvider
    
    init(decoratedRepository: CharacterRepository, translationRepository: TranslationRepository, languageProvider: AppLanguageProvider) {
        self.decoratedRepository = decoratedRepository
        self.translationRepository = translationRepository
        self.languageProvider = languageProvider
    }
    
    func getCharacters(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Character>, Error> {
        decoratedRepository.getCharacters(page: page, name: name)
            .flatMap { [translationRepository, languageProvider] result -> AnyPublisher<PaginatedResult<Character>, Error> in
                Self.translate(characters: result.items, translationRepository: translationRepository, targetLanguage: languageProvider.currentLanguage)
                    .map { translatedCharacters in
                        PaginatedResult(items: translatedCharacters, hasNextPage: result.hasNextPage)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getCharacterDetail(id: Int) -> AnyPublisher<Character, Error> {
        decoratedRepository.getCharacterDetail(id: id)
            .flatMap { [translationRepository, languageProvider] character -> AnyPublisher<Character, Error> in
                Self.translate(character: character, translationRepository: translationRepository, targetLanguage: languageProvider.currentLanguage)
            }
            .eraseToAnyPublisher()
    }
    
    private static func translate(characters: [Character], translationRepository: TranslationRepository, targetLanguage: AppLanguage) -> AnyPublisher<[Character], Error> {
        guard targetLanguage != .english, !characters.isEmpty else {
            return Just(characters)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let publishers = characters.map { character in
            translate(character: character, translationRepository: translationRepository, targetLanguage: targetLanguage)
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { $0.sorted { $0.id < $1.id } }
            .eraseToAnyPublisher()
    }
    
    private static func translate(character: Character, translationRepository: TranslationRepository, targetLanguage: AppLanguage) -> AnyPublisher<Character, Error> {
        guard targetLanguage != .english else {
            return Just(character)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let translatedSpecies = translationRepository
            .translate(character.species, from: .english, to: targetLanguage)
            .replaceError(with: character.species)
        
        let translatedType = translationRepository
            .translate(character.type, from: .english, to: targetLanguage)
            .replaceError(with: character.type)
        
        let translatedGender = translationRepository
            .translate(character.gender, from: .english, to: targetLanguage)
            .replaceError(with: character.gender)
        
        return Publishers.CombineLatest3(translatedSpecies, translatedType, translatedGender)
            .map { species, type, gender in
                Character(
                    id: character.id,
                    name: character.name,
                    status: character.status,
                    species: species,
                    type: type,
                    gender: gender,
                    origin: character.origin,
                    location: character.location,
                    imageURL: character.imageURL,
                    episodeIds: character.episodeIds,
                    image: character.image
                )
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
