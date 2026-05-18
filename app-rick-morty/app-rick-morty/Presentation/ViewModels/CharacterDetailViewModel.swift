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
    
    func viewDidLoad()
    func didSelectLocation(id: Int)
    func didSelectEpisode(id: Int)
}

final class DefaultCharacterDetailViewModel: CharacterDetailViewModel {
    private let characterId: Int
    private let dependencies: CharacterDependencies
    private weak var navigationCoordinator: NavegationCoordinator?
    
    private var cancellables = Set<AnyCancellable>()
    private let characterSubject = CurrentValueSubject<Character?, Never>(nil)
    
    var characterPublisher: AnyPublisher<Character?, Never> {
        characterSubject.eraseToAnyPublisher()
    }
    
    init(characterId: Int, dependencies: CharacterDependencies, navigationCoordinator: NavegationCoordinator) {
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
            }
            .store(in: &cancellables)
    }
}
