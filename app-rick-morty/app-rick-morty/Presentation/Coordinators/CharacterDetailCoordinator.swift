//
//  CharacterDetailCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//
import UIKit

protocol CharacterDetailCoordinator {
    func setCharacterId(_ id: Int)
    func start() -> UIViewController
}

protocol CharacterDetailCoordinatorFactory {
    func createNew(navegationCoordinator: NavegationCoordinator) -> CharacterDetailCoordinator
}

final class DefaultCharacterDetailCoordinatorFactory: CharacterDetailCoordinatorFactory {
    private let dependencies: CharacterDependencies
    
    init(dependencies: CharacterDependencies) {
        self.dependencies = dependencies
    }
    
    func createNew(navegationCoordinator: NavegationCoordinator) -> any CharacterDetailCoordinator {
        return DefaultCharacterDetailCoordinator(dependencies: dependencies, navegationCoordinator: navegationCoordinator)
    }
}


final class DefaultCharacterDetailCoordinator: CharacterDetailCoordinator {
    private let dependencies: CharacterDependencies
    private weak var navegationCoordinator: NavegationCoordinator?
    private var characterId: Int?
    
    init(dependencies: CharacterDependencies, navegationCoordinator: NavegationCoordinator){
        self.dependencies = dependencies
        self.navegationCoordinator = navegationCoordinator
    }
    
    func setCharacterId(_ id: Int) {
        characterId = id
    }
    
    func start() -> UIViewController {
        guard let characterId, let navegationCoordinator else { fatalError("Dependencies not set") }
        
        let viewModel = DefaultCharacterDetailViewModel(characterId: characterId, dependencies: dependencies, navigationCoordinator: navegationCoordinator)
        
        return CharacterDetailViewController(viewModel: viewModel)
    }
}
