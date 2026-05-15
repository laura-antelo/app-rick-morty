//
//  EpisodeListViewModel.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 15/5/26.
//

import Foundation
import Combine

protocol EpisodeListViewModel {
    var episodesPublisher: AnyPublisher<[Episode], Never> { get }
    
    func viewDidLoad()
    func updateSearchText(_ text: String)
}

final class DefaultEpisodeListViewModel: EpisodeListViewModel {
    private let dependencies: RickAndMortyDependencies
    private var cancellables = Set<AnyCancellable>()
    
    private let episodesSubject = CurrentValueSubject<[Episode], Never>([])
    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    
    var episodesPublisher: AnyPublisher<[Episode], Never> {
        episodesSubject.eraseToAnyPublisher()
    }
    
    init(dependencies: RickAndMortyDependencies) {
        self.dependencies = dependencies
    }
    
    func viewDidLoad() {
        bindSearch()
        loadEpisodes(name: nil)
    }
    
    func updateSearchText(_ text: String) {
        searchTextSubject.send(text)
    }
    
    private func bindSearch() {
        searchTextSubject
            .removeDuplicates()
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.loadEpisodes(name: text)
            }
            .store(in: &cancellables)
    }
    
    private func loadEpisodes(name: String?) {
        let useCase: GetEpisodesUseCase = dependencies.resolve()
        
        let cleanedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let searchName = cleanedName?.isEmpty == true ? nil : cleanedName
        
        useCase.execute(page: 1, name: searchName)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] episodes in
                self?.episodesSubject.send(episodes)
            }
            .store(in: &cancellables)
    }
}
