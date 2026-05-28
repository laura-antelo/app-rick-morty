//
//  EpisodeRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import Combine
import UIKit

protocol EpisodeRepository {
    func getEpisodes(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Episode>, Error>
    func getEpisodeDetail(id: Int) -> AnyPublisher<Episode, Error>
}

final class DefaultEpisodeRepository: EpisodeRepository {
    
    private let api: APIClient
    private let imdbApi: IMDbAPIClient
    
    init(api: APIClient, imdbApi: IMDbAPIClient) {
        self.api = api
        self.imdbApi = imdbApi
    }
    
    func getEpisodes(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Episode>, any Error> {
        api.request(.episodes(page: page, name: name), responseType: ResponseDTO<EpisodeDTO>.self)
            .flatMap { [api, imdbApi] response -> AnyPublisher<PaginatedResult<Episode>, Error> in
                let episodes = response.results.map { $0.toDomain() }
                
                return Self.enrich(episodes: episodes, api: api, imdbApi: imdbApi)
                    .map { enrichedEpisodes in
                        PaginatedResult(items: enrichedEpisodes, hasNextPage: response.info.next != nil)
                    }
                    .eraseToAnyPublisher( )
            }
            .eraseToAnyPublisher()
    }
    
    func getEpisodeDetail(id: Int) -> AnyPublisher<Episode, any Error> {
        api.request(.episodeDetail(id: id), responseType: EpisodeDTO.self)
            .flatMap { [api, imdbApi] dto -> AnyPublisher<Episode, Error> in
                let episode = dto.toDomain()
                
                return Self.enrich(episodes: [episode], api: api, imdbApi: imdbApi)
                    .map { $0.first ?? episode }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private static func enrich(episodes: [Episode], api: APIClient, imdbApi: IMDbAPIClient) -> AnyPublisher<[Episode], Error> {
        guard !episodes.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher( )
        }
        
        return imdbApi.request(.episodes, responseType: IMDbEpisodeResponseDTO.self)
            .map { $0.episodes }
            .replaceError(with: [])
            .flatMap { imdbEpisodes -> AnyPublisher<[Episode], Never> in
                let episodePublishers = episodes.map { episode in
                    let imdbEpisode = imdbEpisodes.matchingEpisode(for: episode)
                    
                    return api.fetchImage(from: imdbEpisode?.primaryImage.url)
                        .replaceError(with: nil)
                        .map { image in
                            episode.enriched(with: imdbEpisode, image: image)
                        }
                        .eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(episodePublishers)
                    .collect()
                    .map { $0.sorted { $0.id < $1.id } }
                    .eraseToAnyPublisher()
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private extension EpisodeDTO {
    func toDomain() -> Episode {
        Episode(id: id, name: name, airDate: airDate, code: episode, charactersIds: characters.compactMap{ $0.apiResourceId }, image: nil, synopsis: "", rating: 0, voteCount: 0, season: episode.season, episodeNumber: episode.episodeNumber)
    }
}

private extension Episode {
    func enriched(with imdbEpisode: IMDbEpisodeDTO?, image: UIImage?) -> Episode {
        Episode(id: id, name: name, airDate: airDate, code: code, charactersIds: charactersIds, image: image,
                synopsis: imdbEpisode?.plot ?? "",
                rating: imdbEpisode?.rating.aggregateRating ?? 0,
                voteCount: imdbEpisode?.rating.voteCount ?? 0,
                season: imdbEpisode?.seasonNumber ?? 0,
                episodeNumber: imdbEpisode?.episodeNumber ?? 0)
    }
}

private extension Array where Element == IMDbEpisodeDTO {
    func matchingEpisode(for episode: Episode) -> IMDbEpisodeDTO? {
        first { imdbEpisode in
            imdbEpisode.seasonNumber == episode.season && imdbEpisode.episodeNumber == episode.episodeNumber
        }
    }
}

private extension String {
    var apiResourceId: Int? {
        guard let lastPathComponent = URL(string: self)?.lastPathComponent else { return nil }
        
        return Int(lastPathComponent)
    }
    
    var season: Int {
        episodeCodeValue(at: 1)
    }
    
    var episodeNumber: Int {
        episodeCodeValue(at: 2)
    }
    
    private func episodeCodeValue(at index: Int) -> Int {
        let pattern = #"S(\d+)E(\d+)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: self, range: NSRange(self.startIndex..., in: self)),
              let range = Range(match.range(at: index), in: self) else {
            return 0
        }
        
        return Int(self[range]) ?? 0
    }
}
