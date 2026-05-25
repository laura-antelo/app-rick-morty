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
    var isFavoriteFilterActivePublisher: AnyPublisher<Bool, Never> { get }
    
    func viewDidLoad()
    func updateSearchText(_ text: String)
    func loadMore()
    func didSelectEpisode(id: Int)
    func didTapFavoriteFilter()
}

final class DefaultEpisodeListViewModel: EpisodeListViewModel {
    private let dependencies: EpisodeDependencies
    private var cancellables = Set<AnyCancellable>()
    private var loadCancellable: AnyCancellable?
    
    private let episodesSubject = CurrentValueSubject<[Episode], Never>([])
    private let canLoadMoreSubject = CurrentValueSubject<Bool, Never>(false)
    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    private let isFavoriteFilterActiveSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var currentPage = 1
    private var currentSearchName: String?
    private var isLoading = false
    private var hasNextPage = false
    private var isFavoriteFilterActive = false
    
    var episodesPublisher: AnyPublisher<[Episode], Never> {
        episodesSubject.eraseToAnyPublisher()
    }
    
    var canLoadMorePublisher: AnyPublisher<Bool, Never> {
        canLoadMoreSubject.eraseToAnyPublisher()
    }
    
    var isFavoriteFilterActivePublisher: AnyPublisher<Bool, Never> {
        isFavoriteFilterActiveSubject.eraseToAnyPublisher()
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
    
    func didTapFavoriteFilter() {
        isFavoriteFilterActive.toggle()
        isFavoriteFilterActiveSubject.send(isFavoriteFilterActive)
        loadFirstPage(name: currentSearchName)
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
        
        if isFavoriteFilterActive {
            loadFavoriteEpisodes(name: currentSearchName)
        } else {
            loadEpisodes(page: currentPage, name: currentSearchName, shouldAppend: false)
        }
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
    
    private func loadFavoriteEpisodes(name: String?) {
        let getFavoriteUseCase: GetFavoriteUseCase = dependencies.resolve()
        let getEpisodeDetailUseCase: GetEpisodeDetailUseCase = dependencies.resolve()
        
        let favorites = filterFavorites(getFavoriteUseCase.execute(.episode), name: name)
        
        guard !favorites.isEmpty else {
            episodesSubject.send([])
            return
        }
        
        isLoading = true
        
        loadCancellable = Publishers.Sequence(sequence: favorites)
            .flatMap(maxPublishers: .max(1)) { favorite in
                getEpisodeDetailUseCase.execute(id: favorite.id)
                    .map { Optional($0) }
                    .replaceError(with: nil)
            }
            .compactMap { $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] episodes in
                guard let self = self else { return }
                
                self.isLoading = false
                self.hasNextPage = false
                self.episodesSubject.send(episodes)
            }
    }
    
    private func filterFavorites(_ favorites: [Favorite], name: String?) -> [Favorite] {
        guard let name else { return favorites }
        
        return favorites.filter { favorite in
            favorite.name.localizedCaseInsensitiveContains(name)
        }
    }
    
    private func cleanSearchName(_ name: String?) -> String? {
        let cleanedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanedName?.isEmpty == false ? cleanedName : nil
    }
}
