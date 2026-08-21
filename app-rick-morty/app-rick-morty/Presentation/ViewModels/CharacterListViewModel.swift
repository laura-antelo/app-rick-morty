//
//  CharacteListViewModel.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 15/5/26.
//

import Foundation
import Combine

protocol CharacterListViewModel {
    var charactersPublisher: AnyPublisher<[Character], Never> { get }
    var canLoadMorePublisher: AnyPublisher<Bool, Never> { get }
    var isFavoriteFilterActivePublisher: AnyPublisher<Bool, Never> { get }
    
    func viewDidLoad()
    func updateSearchText(_ text: String)
    func loadMore()
    func didSelectCharacter(id: Int)
    func didTapFavoriteFilter()
}

final class DefaultCharacterListViewModel: CharacterListViewModel {
    private let dependencies: CharacterDependencies
    private var cancellables = Set<AnyCancellable>()
    private var loadCancellable: AnyCancellable?
    
    private let charactersSubject = CurrentValueSubject<[Character], Never>([])
    private let canLoadMoreSubject = CurrentValueSubject<Bool, Never>(false)
    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    private let isFavoriteFilterActiveSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var currentPage = 1
    private var currentSearchName: String?
    private var isLoading = false
    private var hasNextPage = false
    private var isFavoriteFilterActive = false
    
    var charactersPublisher: AnyPublisher<[Character], Never> {
        charactersSubject.eraseToAnyPublisher()
    }
    
    var canLoadMorePublisher: AnyPublisher<Bool, Never> {
        canLoadMoreSubject.eraseToAnyPublisher()
    }
    
    var isFavoriteFilterActivePublisher: AnyPublisher<Bool, Never> {
        isFavoriteFilterActiveSubject.eraseToAnyPublisher()
    }
    
    init(dependencies: CharacterDependencies) {
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
        
        loadCharacters(page: currentPage + 1, name: currentSearchName, shouldAppend: true)
    }
    
    func didSelectCharacter(id: Int) {
        let coordinator: CharacterCoordinator = dependencies.resolve()
        coordinator.goToCharacterDetail(id: id)
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
            loadFavoriteCharacters(name: currentSearchName)
        } else {
            loadCharacters(page: currentPage, name: currentSearchName, shouldAppend: false)
        }
        }
    
    private func loadCharacters(page: Int, name: String?, shouldAppend: Bool) {
        guard !isLoading else { return }
        isLoading = true
        
        let useCase: GetCharactersUseCase = dependencies.resolve()
        let emptyResult = PaginatedResult<Character>(items: [], hasNextPage: false)
        
        loadCancellable = useCase.execute(page: page, name: name)
            .replaceError(with: emptyResult)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                self.isLoading = false
                self.currentPage = page
                self.hasNextPage = result.hasNextPage
                self.canLoadMoreSubject.send(self.hasNextPage)
                
                let characters = shouldAppend ? self.charactersSubject.value + result.items : result.items
                self.charactersSubject.send(characters)
            }
    }
    
    private func loadFavoriteCharacters(name: String?) {
        let getFavoriteUseCase: GetFavoriteUseCase = dependencies.resolve()
        let getCharacterDetailUseCsae: GetCharacterDetailUseCase = dependencies.resolve()
        
        let favorites = filterFavorites(getFavoriteUseCase.execute(.character), name: name)
        
        guard !favorites.isEmpty else {
            charactersSubject.send([])
            return
        }
        
        isLoading = true
        
        loadCancellable = Publishers.Sequence(sequence: favorites)
            .flatMap(maxPublishers: .max(1)) { favorite in
                getCharacterDetailUseCsae.execute(id: favorite.id)
                    .map { Optional($0) }
                    .replaceError(with: nil)
            }
            .compactMap { $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characters in
                guard let self = self else { return }
                
                self.isLoading = false
                self.hasNextPage = false
                self.charactersSubject.send(characters)
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
