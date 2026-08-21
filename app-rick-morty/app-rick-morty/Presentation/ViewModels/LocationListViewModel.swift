//
//  LocationListViewModel.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 15/5/26.
//

import Foundation
import Combine

protocol LocationListViewModel {
    var locationsPublisher: AnyPublisher<[Location], Never> { get }
    var canLoadMorePublisher: AnyPublisher<Bool, Never> { get }
    var isFavoriteFilterActivePublisher: AnyPublisher<Bool, Never> { get }
    
    func viewDidLoad()
    func updateSearchText(_ text: String)
    func loadMore()
    func didSelectLocation(id: Int)
    func didTapFavoriteFilter()
}

final class DefaultLocationListViewModel: LocationListViewModel {
    private let dependencies: LocationDependencies
    private var cancellables = Set<AnyCancellable>()
    private var loadCancellable: AnyCancellable?
    
    private let locationsSubject = CurrentValueSubject<[Location], Never>([])
    private let canLoadMoreSubject = CurrentValueSubject<Bool, Never>(false)
    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    private let isFavoriteFilterActiveSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var currentPage = 1
    private var currentSearchName: String?
    private var isLoading = false
    private var hasNextPage = false
    private var isFavoriteFilterActive = false
    
    var locationsPublisher: AnyPublisher<[Location], Never> {
        locationsSubject.eraseToAnyPublisher()
    }
    
    var canLoadMorePublisher: AnyPublisher<Bool, Never> {
        canLoadMoreSubject.eraseToAnyPublisher()
    }
    
    var isFavoriteFilterActivePublisher: AnyPublisher<Bool, Never> {
        isFavoriteFilterActiveSubject.eraseToAnyPublisher()
    }
    
    init(dependencies: LocationDependencies) {
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
        
        loadLocations(page: currentPage + 1, name: currentSearchName, shouldAppend: true)
    }
    
    func didSelectLocation(id: Int) {
        let coordinator: LocationCoordinator = dependencies.resolve()
        coordinator.goToLocationDetail(id: id)
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
            loadFavoriteLocations(name: currentSearchName)
        } else {
            loadLocations(page: currentPage, name: currentSearchName, shouldAppend: false)
        }
    }
    
    private func loadLocations(page: Int, name: String?, shouldAppend: Bool) {
        guard !isLoading else { return }
        isLoading = true
        
        let useCase: GetLocationsUseCase = dependencies.resolve()
        let emptyResult = PaginatedResult<Location>(items: [], hasNextPage: false)
        
        loadCancellable = useCase.execute(page: page, name: name)
            .replaceError(with: emptyResult)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                self.isLoading = false
                self.currentPage = page
                self.hasNextPage = result.hasNextPage
                self.canLoadMoreSubject.send(self.hasNextPage)
                
                let locations = shouldAppend ? self.locationsSubject.value + result.items : result.items
                self.locationsSubject.send(locations)
            }
    }
    
    private func loadFavoriteLocations(name: String?) {
        let getFavoriteUseCase: GetFavoriteUseCase = dependencies.resolve()
        let getLocationDetailUseCase: GetLocationDetailUseCase = dependencies.resolve()
        
        let favorites = filterFavorites(getFavoriteUseCase.execute(.location), name: name)
        
        guard !favorites.isEmpty else {
            locationsSubject.send([])
            return
        }
        
        isLoading = true
        
        loadCancellable = Publishers.Sequence(sequence: favorites)
            .flatMap(maxPublishers: .max(1)) { favorite in
                getLocationDetailUseCase.execute(id: favorite.id)
                    .map { Optional($0) }
                    .replaceError(with: nil)
            }
            .compactMap { $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locations in
                guard let self = self else { return }
                
                self.isLoading = false
                self.hasNextPage = false
                self.locationsSubject.send(locations)
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
