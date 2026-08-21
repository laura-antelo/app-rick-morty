//
//  IMDbEpisodeRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 29/5/26.
//


import Foundation
import Combine

protocol IMDbEpisodeRepository {
    func getEpisodes(season: Int) -> AnyPublisher<[IMDbEpisode], Error>
}

final class DefaultIMDbEpisodeRepository: IMDbEpisodeRepository {
    private let api: IMDbAPIClient
    private let imageRepository: ImageRepository
    
    init(api: IMDbAPIClient, imageRepository: ImageRepository) {
        self.api = api
        self.imageRepository = imageRepository
    }
    
    func getEpisodes(season: Int) -> AnyPublisher<[IMDbEpisode], Error>{
        fetchAllEpisodes(pageToken: nil, accumulatedEpisodes: [])
            .map { episodes in
                episodes.filter { Int($0.season) == season }
            }
            .flatMap { [imageRepository] episodeDTO in
                Self.mapEpisodes(episodeDTO, imageRepository: imageRepository)
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchAllEpisodes(pageToken: String?, accumulatedEpisodes: [IMDbEpisodeDTO]) -> AnyPublisher<[IMDbEpisodeDTO], Error> {
        api.request(.episodes(nextPageToken: pageToken), responseType: IMDbEpisodeResponseDTO.self)
            .flatMap { [weak self] response -> AnyPublisher<[IMDbEpisodeDTO], Error> in
                let allEpisodes = accumulatedEpisodes + response.episodes
                
                guard let self, let nextPageToken = response.nextPageToken, nextPageToken != pageToken else {
                    return Just(allEpisodes)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.fetchAllEpisodes(pageToken: response.nextPageToken, accumulatedEpisodes: allEpisodes)
            }
            .eraseToAnyPublisher()
    }
    
    private static func mapEpisodes(_ episodesDTO: [IMDbEpisodeDTO], imageRepository: ImageRepository) -> AnyPublisher<[IMDbEpisode], Error> {
        guard !episodesDTO.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let publishers = episodesDTO.map { dto in
            imageRepository.getImage(from: dto.primaryImage.url)
                .replaceError(with: nil)
                .map { image in
                    dto.toDomain(image: image)
                }
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { episodes in
                episodes.sorted { $0.episodeNumber < $1.episodeNumber }
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
