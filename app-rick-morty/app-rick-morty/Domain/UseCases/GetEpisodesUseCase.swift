//
//  GetEpisodesUseCase.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import Combine

protocol GetEpisodesUseCase {
    func execute(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Episode>, Error>
}

final class DefaultGetEpisodesUseCase: GetEpisodesUseCase {
    private let repository: EpisodeRepository
    
    init(repository: EpisodeRepository) {
        self.repository = repository
    }
    
    func execute(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Episode>, any Error> {
        return repository.getEpisodes(page: page, name: name)
    }
}
