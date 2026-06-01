//
//  EnrichedEpisodeRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 29/5/26.
//

import Foundation
import Combine

final class EnrichedEpisodeRepository: EpisodeRepository {
    private let episodeRepository: EpisodeRepository
    private let imdbEpisodeRepository: IMDbEpisodeRepository
    
    init(episodeRepository: EpisodeRepository, imdbEpisodeRepository: IMDbEpisodeRepository) {
        self.episodeRepository = episodeRepository
        self.imdbEpisodeRepository = imdbEpisodeRepository
    }
    
    func getEpisodes(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Episode>, any Error> {
        episodeRepository.getEpisodes(page: page, name: name)
            .flatMap { [imdbEpisodeRepository] result -> AnyPublisher<PaginatedResult<Episode>, Error> in
                Self.enrich(episodes: result.items, imdbEpisodeRepository: imdbEpisodeRepository)
                    .map { enrichedEpisodes in
                        PaginatedResult(items: enrichedEpisodes, hasNextPage: result.hasNextPage)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getEpisodeDetail(id: Int) -> AnyPublisher<Episode, any Error> {
        episodeRepository.getEpisodeDetail(id: id)
            .flatMap { [imdbEpisodeRepository] episode -> AnyPublisher<Episode, Error> in
                Self.enrich(episodes: [episode], imdbEpisodeRepository: imdbEpisodeRepository)
                    .map { $0.first ?? episode }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private static func  enrich(episodes: [Episode], imdbEpisodeRepository: IMDbEpisodeRepository) -> AnyPublisher<[Episode], Error> {
        let seasons = Array(Set(episodes.map { $0.season })).filter { $0 > 0 }
        
        guard !episodes.isEmpty, !seasons.isEmpty else {
            return Just(episodes)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let publishers = seasons.map { season in
            imdbEpisodeRepository.getEpisodes(season: season)
                .catch { error -> Just<[IMDbEpisode]> in
                    return Just([])
                }
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { imdbEpisodesBySeason in
                let imdbEpisodes = imdbEpisodesBySeason.flatMap { $0 }
                
                return episodes.map { episode in
                    let imdbEpisode = imdbEpisodes.matchingEpisode(for: episode)
                    
                    return episode.enriched(with: imdbEpisode)
                }
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private extension Episode {
    func enriched(with imdbEpisode: IMDbEpisode?) -> Episode {
        return Episode(id: id, name: name, airDate: airDate, code: code, charactersIds: charactersIds, image: imdbEpisode?.image ?? image, synopsis: imdbEpisode?.synopsis ?? synopsis, rating: imdbEpisode?.rating ?? rating, voteCount: imdbEpisode?.voteCount ?? voteCount, season: imdbEpisode?.season ?? season, episodeNumber: imdbEpisode?.episodeNumber ?? episodeNumber)
    }
}

private extension Array where Element == IMDbEpisode {
    func matchingEpisode(for episode: Episode) -> IMDbEpisode? {
        first { imdbEpisode in
            imdbEpisode.season == episode.season && imdbEpisode.episodeNumber == episode.episodeNumber
        }
    }
}
