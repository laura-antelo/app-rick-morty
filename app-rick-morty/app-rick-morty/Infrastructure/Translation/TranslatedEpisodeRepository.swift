//
//  TranslatedEpisodeRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 3/6/26.
//

import Foundation
import Combine

final class TranslatedEpisodeRepository: EpisodeRepository {
    
    private let decoratedRepository: EpisodeRepository
    private let translationRepository: TranslationRepository
    private let languageProvider: AppLanguageProvider
    
    init(decoratedRepository: EpisodeRepository, translationRepository: TranslationRepository, languageProvider: AppLanguageProvider) {
        self.decoratedRepository = decoratedRepository
        self.translationRepository = translationRepository
        self.languageProvider = languageProvider
    }
    
    func getEpisodes(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Episode>, Error> {
        decoratedRepository.getEpisodes(page: page, name: name)
            .flatMap { [translationRepository, languageProvider] result -> AnyPublisher<PaginatedResult<Episode>, Error> in
                Self.translate(episodes: result.items, translationRepository: translationRepository, targetLanguage: languageProvider.currentLanguage)
                    .map { translatedEpisodes in
                        PaginatedResult(items: translatedEpisodes, hasNextPage: result.hasNextPage)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getEpisodeDetail(id: Int) -> AnyPublisher<Episode, Error> {
        decoratedRepository.getEpisodeDetail(id: id)
            .flatMap{ [translationRepository, languageProvider] episode -> AnyPublisher<Episode, Error> in
                Self.translate(episode: episode, translationRepository: translationRepository, targetLanguage: languageProvider.currentLanguage)
            }
            .eraseToAnyPublisher()
    }
    
    private static func translate(episodes: [Episode], translationRepository: TranslationRepository, targetLanguage: AppLanguage) -> AnyPublisher<[Episode], Error> {
        guard targetLanguage != .english, !episodes.isEmpty else {
            return Just(episodes)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let publishers = episodes.map { episode in
            translate(episode: episode, translationRepository: translationRepository, targetLanguage: targetLanguage)
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { $0.sorted { $0.id < $1.id } }
            .eraseToAnyPublisher()
    }
    
    private static func translate(episode: Episode, translationRepository: TranslationRepository, targetLanguage: AppLanguage) -> AnyPublisher<Episode, Error> {
        guard targetLanguage != .english else {
            return Just(episode)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let translatedName = translationRepository
            .translate(episode.name, from: .english, to: targetLanguage)
            .replaceError(with: episode.name)
        
        let translatedSynopsis = translationRepository
            .translate(episode.synopsis, from: .english, to: targetLanguage)
            .replaceError(with: episode.synopsis)
        
        return Publishers.CombineLatest(translatedName, translatedSynopsis)
            .map { name, synopsis in
                Episode(
                    id: episode.id,
                    name: name,
                    airDate: episode.airDate,
                    code: episode.code,
                    charactersIds: episode.charactersIds,
                    image: episode.image,
                    synopsis: synopsis,
                    rating: episode.rating,
                    voteCount: episode.voteCount,
                    season: episode.season,
                    episodeNumber: episode.episodeNumber
                )
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
