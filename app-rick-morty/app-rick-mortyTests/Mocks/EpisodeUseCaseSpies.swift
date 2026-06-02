//
//  EpisodeUseCaseSpies.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import Combine
@testable import app_rick_morty

final class GetEpisodesUseCaseSpy: GetEpisodesUseCase {
    var receivedPage: Int?
    var receivedName: String?
    
    var result: Result<PaginatedResult<Episode>, Error> = .success(PaginatedResult(items: [], hasNextPage: false))
    
    func execute(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Episode>, any Error> {
        receivedName = name
        receivedPage = page
        
        return result.publisher.eraseToAnyPublisher()
    }
}

final class GetEpisodeDetailUseCaseSpy: GetEpisodeDetailUseCase {
    var receivedId: Int?
    
    var result: Result<Episode, Error> = .success(TestRickAndMortyData.episode)
    
    func execute(id: Int) -> AnyPublisher<Episode, any Error> {
        receivedId = id
        
        return result.publisher.eraseToAnyPublisher()
    }
}
