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
    
    var charactersResult: Result<[Episode], Error> = .success([])
    var characterDetailResult: Result<Episode, Error> = .success(TestRickAndMortyData.episode)
    
    func getEpisodes(page: Int?, name: String?) -> AnyPublisher<[Episode], any Error> {
        getEpisodesPage = page
        getEpisodesName = name
        
        return charactersResult.publisher.eraseToAnyPublisher()
    }
    
    func getEpisodeDetail(id: Int) -> AnyPublisher<Episode, any Error> {
        getEpisodeDetailId = id
        
        return characterDetailResult.publisher.eraseToAnyPublisher()
    }
}
