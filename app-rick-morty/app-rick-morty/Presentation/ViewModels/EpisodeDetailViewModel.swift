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
    var relatedCharactersPublisher: AnyPublisher<[Character], Never> { get }
    var isFavoritePublisher: AnyPublisher<Bool, Never> { get }
    
    func viewDidLoad()
    func didSelectCharacter(id: Int)
    func didTapFavorite()
}

final class DefaultEpisodeDetailViewModel: EpisodeDetailViewModel {
    private let episodeId: Int
    private let dependencies: RickAndMortyDependencies
    private weak var navigationCoordinator: NavegationCoordinator?
    
    private var cancellables = Set<AnyCancellable>()
    private let episodeSubject = CurrentValueSubject<Episode?, Never>(nil)
    private let relatedCharactersSubject = CurrentValueSubject<[Character], Never>([])
    private let isFavoriteSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var currentEpisode: Episode?
    
    var relatedCharactersPublisher: AnyPublisher<[Character], Never> {
        relatedCharactersSubject.eraseToAnyPublisher()
    }
    
    var episodePublisher: AnyPublisher<Episode?, Never> {
        episodeSubject.eraseToAnyPublisher()
    }
    
    var isFavoritePublisher: AnyPublisher<Bool, Never> {
        isFavoriteSubject.eraseToAnyPublisher()
    }
    
    init(episodeId: Int, dependencies: RickAndMortyDependencies, navigationCoordinator: NavegationCoordinator) {
        self.episodeId = episodeId
        self.dependencies = dependencies
        self.navigationCoordinator = navigationCoordinator
    }
    
    func viewDidLoad() {
        loadEpisode()
    }
    
    func didSelectCharacter(id: Int) {
        navigationCoordinator?.goToCharacterDetail(id: id)
    }
    
    func didTapFavorite() {
        guard let currentEpisode else { return }
        
        let favorite = Favorite(id: currentEpisode.id, type: .episode, name: currentEpisode.name)
        
        let useCase: ToggleFavoriteUseCase = dependencies.resolve()
        let isFavorite = useCase.execute(favorite)
        
        isFavoriteSubject.send(isFavorite)
    }
    
    private func loadEpisode() {
        let useCase: GetEpisodeDetailUseCase = dependencies.resolve()
        
        useCase.execute(id: episodeId)
            .receive(on: DispatchQueue.main)
            .sink{ completion in
                if case .failure(let error) = completion {
                    print("ERROR loading episode detail:", error)
                }
            } receiveValue: { [weak self] episode in
                guard let self = self else { return }
                self.currentEpisode = episode
                self.episodeSubject.send(episode)
                self.updateFavoriteState(episode: episode)
                self.loadRelatedCharacters(ids: episode.charactersIds)
            }
            .store(in: &cancellables)
    }
    
    private func updateFavoriteState(episode: Episode) {
        let favorite = Favorite(id: episode.id, type: .episode, name: episode.name)
        
        let useCase: IsFavoriteUseCase = dependencies.resolve()
        let isFavorite = useCase.execute(favorite)
        
        isFavoriteSubject.send(isFavorite)
    }
    
    private func loadRelatedCharacters(ids: [Int]) {
        guard !ids.isEmpty else {
            relatedCharactersSubject.send([])
            return
        }
        
        let useCase: GetCharacterDetailUseCase = dependencies.resolve()
        ids.publisher
            .flatMap(maxPublishers: .max(4)) { id in
                useCase.execute(id: id)
                    .map { Optional($0) }
                    .replaceError(with: nil)
            }
            .compactMap{ $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characters in
                self?.relatedCharactersSubject.send(characters)
            }
            .store(in: &cancellables)
    }
}
