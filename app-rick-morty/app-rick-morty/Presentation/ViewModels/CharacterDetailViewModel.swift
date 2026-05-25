//
//  CharacterDetailViewModel.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 15/5/26.
//

import Foundation
import Combine

protocol CharacterDetailViewModel {
    var characterPublisher: AnyPublisher<Character?, Never> { get }
    var relatedEpisodesPublisher: AnyPublisher<[Episode], Never> { get }
    
    func viewDidLoad()
    func didSelectLocation(id: Int)
    func didSelectEpisode(id: Int)
}

final class DefaultCharacterDetailViewModel: CharacterDetailViewModel {
    private let characterId: Int
    private let dependencies: RickAndMortyDependencies
    private weak var navigationCoordinator: NavegationCoordinator?
    
    private var cancellables = Set<AnyCancellable>()
    private let characterSubject = CurrentValueSubject<Character?, Never>(nil)
    private let relatedEpisodesSubject = CurrentValueSubject<[Episode], Never>([])
    
    var characterPublisher: AnyPublisher<Character?, Never> {
        characterSubject.eraseToAnyPublisher()
    }
    
    var relatedEpisodesPublisher: AnyPublisher<[Episode], Never> {
        relatedEpisodesSubject.eraseToAnyPublisher()
    }
    
    init(characterId: Int, dependencies: RickAndMortyDependencies, navigationCoordinator: NavegationCoordinator) {
        self.characterId = characterId
        self.dependencies = dependencies
        self.navigationCoordinator = navigationCoordinator
    }
    
    func viewDidLoad() {
        loadCharacter()
    }
    
    func didSelectEpisode(id: Int) {
        navigationCoordinator?.goToEpisodeDetail(id: id)
    }
    
    func didSelectLocation(id: Int) {
        navigationCoordinator?.goToLocationDetail(id: id)
    }
    
    private func loadCharacter() {
        let useCase: GetCharacterDetailUseCase = dependencies.resolve()
        
        useCase.execute(id: characterId)
            .receive(on: DispatchQueue.main)
            .sink{ completion in
                if case .failure(let error) = completion {
                    print("ERROR loading character detail:", error)
                }
            } receiveValue: { [weak self] character in
                self?.characterSubject.send(character)
                self?.loadRelatedEpisodes(ids: character.episodeIds)
            }
            .store(in: &cancellables)
    }
    
    private func loadRelatedEpisodes(ids: [Int]) {
        guard !ids.isEmpty else {
            relatedEpisodesSubject.send([])
            return
        }
        
        let useCase: GetEpisodeDetailUseCase = dependencies.resolve()
        ids.publisher
            .flatMap(maxPublishers: .max(4)) { id in
                useCase.execute(id: id)
                    .map { Optional($0) }
                    .replaceError(with: nil)
            }
            .compactMap{ $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] episodes in
                self?.relatedEpisodesSubject.send(episodes)
            }
            .store(in: &cancellables)
    }
}
