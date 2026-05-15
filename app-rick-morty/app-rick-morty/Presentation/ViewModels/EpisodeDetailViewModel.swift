//
//  EpisodeDetailViewModel.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 15/5/26.
//

import Foundation
import Combine

protocol EpisodeDetailViewModel {
    var episodePublisher: AnyPublisher<Episode?, Never> { get }
    
    func viewDidLoad()
}

final class DefaultEpisodeDetailViewModel: EpisodeDetailViewModel {
    private let episodeId: Int
    private let dependencies: RickAndMortyDependencies
    private var cancellables = Set<AnyCancellable>()
    
    private let episodeSubject = CurrentValueSubject<Episode?, Never>(nil)
    
    var episodePublisher: AnyPublisher<Episode?, Never> {
        episodeSubject.eraseToAnyPublisher()
    }
    
    init(episodeId: Int, dependencies: RickAndMortyDependencies) {
        self.episodeId = episodeId
        self.dependencies = dependencies
    }
    
    func viewDidLoad() {
        loadEpisode()
    }
    
    private func loadEpisode() {
        let useCase: GetEpisodeDetailUseCase = dependencies.resolve()
        
        useCase.execute(id: episodeId)
            .receive(on: DispatchQueue.main)
            .sink{ completion in
                if case .failure(let error) = completion {
                    print("ERROR loading character detail:", error)
                }
            } receiveValue: { [weak self] episode in
                self?.episodeSubject.send(episode)
            }
            .store(in: &cancellables)
    }
}
