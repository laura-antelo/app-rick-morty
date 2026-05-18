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
    
    func viewDidLoad()
    func updateSearchText(_ text: String)
    func didSelectCharacter(id: Int)
}

final class DefaultCharacterListViewModel: CharacterListViewModel {
    private let dependencies: CharacterDependencies
    private var cancellables = Set<AnyCancellable>()
    
    private let charactersSubject = CurrentValueSubject<[Character], Never>([])
    private let searchTextSubject = CurrentValueSubject<String, Never>("")
    
    var charactersPublisher: AnyPublisher<[Character], Never> {
        charactersSubject.eraseToAnyPublisher()
    }
    
    init(dependencies: CharacterDependencies) {
        self.dependencies = dependencies
    }
    
    func viewDidLoad() {
        bindSearch()
        loadCharacters(name: nil)
    }
    
    func updateSearchText(_ text: String) {
        searchTextSubject.send(text)
    }
    
    func didSelectCharacter(id: Int) {
        let coordinator: CharacterCoordinator = dependencies.resolve()
        coordinator.goToCharacterDetail(id: id)
    }
    
    private func bindSearch() {
        searchTextSubject
            .removeDuplicates()
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.loadCharacters(name: text)
            }
            .store(in: &cancellables)
    }
    
    private func loadCharacters(name: String?) {
        let useCase: GetCharactersUseCase = dependencies.resolve()
        
        let cleanedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let searchName = cleanedName?.isEmpty == true ? nil : cleanedName
        
        useCase.execute(page: 1, name: searchName)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characters in
                self?.charactersSubject.send(characters)
            }
            .store(in: &cancellables)
    }
}
