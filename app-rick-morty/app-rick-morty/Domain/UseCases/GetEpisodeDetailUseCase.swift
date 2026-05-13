//
//  GetEpisodeDetailUseCase.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import Combine

protocol GetEpisodeDetailUseCase {
    func execute(id: Int) -> AnyPublisher<Episode, Error>
}

final class DefaultGetEpisodeDetailUseCase: GetEpisodeDetailUseCase {
    private let repository: EpisodeRepository
    
    init(repository: EpisodeRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) -> AnyPublisher<Episode, any Error> {
        return repository.getEpisodeDetail(id: id)
    }
}
