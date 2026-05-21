//
//  CharacterDetailCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//
import UIKit

protocol CharacterDetailCoordinator {
    func start() -> UIViewController
}

protocol CharacterDetailCoordinatorFactory {
    func createNew(characterId: Int, navigationCoordinator: NavegationCoordinator) -> CharacterDetailCoordinator
}

final class DefaultCharacterDetailCoordinatorFactory: CharacterDetailCoordinatorFactory {
    private let dependencies: CharacterDependencies
    
    init(dependencies: CharacterDependencies) {
        self.dependencies = dependencies
    }
    
    func createNew(characterId: Int, navigationCoordinator: NavegationCoordinator) -> CharacterDetailCoordinator {
        return DefaultCharacterDetailCoordinator(dependencies: dependencies, characterId: characterId, navigationCoordinator: navigationCoordinator)
    }
}


final class DefaultCharacterDetailCoordinator: CharacterDetailCoordinator {
    
    private let dependencies: CharacterDependencies
    private let characterId: Int
    private let navigationCoordinator: NavegationCoordinator
    
    init(dependencies: CharacterDependencies, characterId: Int, navigationCoordinator: NavegationCoordinator){
        self.dependencies = dependencies
        self.characterId = characterId
        self.navigationCoordinator = navigationCoordinator
    }
    
    func start() -> UIViewController {
        let viewModel = DefaultCharacterDetailViewModel(characterId: characterId, dependencies: dependencies, navigationCoordinator: navigationCoordinator)
        
        return CharacterDetailViewController(viewModel: viewModel)
    }
}
