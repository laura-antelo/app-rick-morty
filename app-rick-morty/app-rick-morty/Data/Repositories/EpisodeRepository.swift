//
//  EpisodeRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import Combine

protocol EpisodeRepository {
    func getEpisodes(page: Int?, name: String?) -> AnyPublisher<[Episode], Error>
    func getEpisodeDetail(id: Int) -> AnyPublisher<Episode, Error>
}

final class DefaultEpisodeRepository: EpisodeRepository {
    
    private let api: APIClient
    
    init(api: APIClient) {
        self.api = api
    }
    
    func getEpisodes(page: Int?, name: String?) -> AnyPublisher<[Episode], any Error> {
        api.request(.episodes(page: page, name: name), responseType: ResponseDTO<EpisodeDTO>.self)
            .map { response in
                response.results.map { $0.toDomain() }
            }.eraseToAnyPublisher()
    }
    
    func getEpisodeDetail(id: Int) -> AnyPublisher<Episode, any Error> {
        api.request(.episodeDetail(id: id), responseType: EpisodeDTO.self).map { dto in
            dto.toDomain()
        }.eraseToAnyPublisher( )
    }
}

private extension EpisodeDTO {
    func toDomain() -> Episode {
        Episode(id: id, name: name, airDate: airDate, code: episode, charactersIds: characters.compactMap { $0.apiResourceId})
    }
}

private extension String {
    var apiResourceId: Int? {
        guard let lastPathComponent = URL(string: self)?.lastPathComponent else { return nil }
        
        return Int(lastPathComponent)
    }
}
