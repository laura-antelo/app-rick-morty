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
    
    func viewDidLoad()
    func updateSearchText(_ text: String)
}

final class DefaultLocationListViewModel: LocationListViewModel {
    private let dependencies: RickAndMortyDependencies
    private var cancellables = Set<AnyCancellable>()
    
    private let locationsSubject = CurrentValueSubject<[Location], Never>([])
    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    
    var locationsPublisher: AnyPublisher<[Location], Never> {
        locationsSubject.eraseToAnyPublisher()
    }
    
    init(dependencies: RickAndMortyDependencies) {
        self.dependencies = dependencies
    }
    
    func viewDidLoad() {
        bindSearch()
        loadLocations(name: nil)
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
                self?.loadLocations(name: text)
            }
            .store(in: &cancellables)
    }
    
    private func loadLocations(name: String?) {
        let useCase: GetLocationsUseCase = dependencies.resolve()
        
        let cleanedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let searchName = cleanedName?.isEmpty == true ? nil : cleanedName
        
        useCase.execute(page: 1, name: searchName)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locations in
                self?.locationsSubject.send(locations)
            }
            .store(in: &cancellables)
    }
}
