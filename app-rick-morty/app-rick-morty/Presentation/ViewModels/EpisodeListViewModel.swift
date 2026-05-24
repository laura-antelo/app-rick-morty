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
    var canLoadMorePublisher: AnyPublisher<Bool, Never> { get }
    
    func viewDidLoad()
    func updateSearchText(_ text: String)
    func loadMore()
    func didSelectEpisode(id: Int)
}

final class DefaultEpisodeListViewModel: EpisodeListViewModel {
    private let dependencies: EpisodeDependencies
    private var cancellables = Set<AnyCancellable>()
    private var loadCancellable: AnyCancellable?
    
    private let episodesSubject = CurrentValueSubject<[Episode], Never>([])
    private let canLoadMoreSubject = CurrentValueSubject<Bool, Never>(false)
    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    
    private var currentPage = 1
    private var currentSearchName: String?
    private var isLoading = false
    private var hasNextPage = false
    
    var episodesPublisher: AnyPublisher<[Episode], Never> {
        episodesSubject.eraseToAnyPublisher()
    }
    
    var canLoadMorePublisher: AnyPublisher<Bool, Never> {
        canLoadMoreSubject.eraseToAnyPublisher()
    }
    
    init(dependencies: EpisodeDependencies) {
        self.dependencies = dependencies
    }
    
    func viewDidLoad() {
        bindSearch()
        loadFirstPage(name: nil)
    }
    
    func updateSearchText(_ text: String) {
        searchTextSubject.send(text)
    }
    
    func loadMore() {
        guard !isLoading, hasNextPage else { return }
        
        loadEpisodes(page: currentPage + 1, name: currentSearchName, shouldAppend: true)
    }
    
    func didSelectEpisode(id: Int) {
        let coordinator: EpisodeCoordinator = dependencies.resolve()
        coordinator.goToEpisodeDetail(id: id)
    }
    
    private func bindSearch() {
        searchTextSubject
            .removeDuplicates()
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.loadFirstPage(name: text)
            }
            .store(in: &cancellables)
    }
    
    private func loadFirstPage(name: String?) {
        loadCancellable?.cancel()
        isLoading = false
        currentSearchName = cleanSearchName(name)
        currentPage = 1
        hasNextPage = false
        canLoadMoreSubject.send(false)
        loadEpisodes(page: currentPage, name: currentSearchName, shouldAppend: false)
    }
    
    private func loadEpisodes(page: Int, name: String?, shouldAppend: Bool) {
        guard !isLoading else { return }
        isLoading = true
        
        let useCase: GetEpisodesUseCase = dependencies.resolve()
        let emptyResult = PaginatedResult<Episode>(items: [], hasNextPage: false)
        
        loadCancellable = useCase.execute(page: page, name: name)
            .replaceError(with: emptyResult)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                self.isLoading = false
                self.currentPage = page
                self.hasNextPage = result.hasNextPage
                self.canLoadMoreSubject.send(self.hasNextPage)
                
                let episodes = shouldAppend ? self.episodesSubject.value + result.items : result.items
                self.episodesSubject.send(episodes)
            }
    }
    
    private func cleanSearchName(_ name: String?) -> String? {
        let cleanedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanedName?.isEmpty == false ? cleanedName : nil
    }
}
