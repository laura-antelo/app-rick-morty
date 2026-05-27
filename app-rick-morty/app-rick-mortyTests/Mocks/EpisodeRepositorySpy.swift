//
//  EpisodeRepositorySpy.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import Combine
@testable import app_rick_morty

final class EpisodeRepositorySpy: EpisodeRepository {
    var getEpisodesPage: Int?
    var getEpisodesName: String?
    var getEpisodeDetailId: Int?
    
    var episodesResult: Result<PaginatedResult<Episode>, Error> = .success(PaginatedResult(items: [], hasNextPage: false))
    var episodeDetailResult: Result<Episode, Error> = .success(TestRickAndMortyData.episode)
    
    func getEpisodes(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Episode>, any Error> {
        getEpisodesPage = page
        getEpisodesName = name
        
        return episodesResult.publisher.eraseToAnyPublisher()
    }
    
    func getEpisodeDetail(id: Int) -> AnyPublisher<Episode, any Error> {
        getEpisodeDetailId = id
        
        return episodeDetailResult.publisher.eraseToAnyPublisher()
    }
}
