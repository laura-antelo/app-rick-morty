//
//  CharacterCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

protocol CharacterCoordinator: NavegationCoordinator {
    func start() -> UIViewController
}

final class DefaultCharacterCoordinator: CharacterCoordinator {
    private let dependencies: RickAndMortyDependencies
    private weak var characterViewController: UIViewController?
    
    init(dependencies: RickAndMortyDependencies) {
        self.dependencies = dependencies
    }
    
    func start() -> UIViewController {
        let viewController: CharacterListViewController = dependencies.resolve()
        
        characterViewController = viewController
        
        return viewController
    }
    
    func goToCharacterDetail(id: Int) {
        let characterDetailCoordinatorFactory: CharacterDetailCoordinatorFactory = dependencies.resolve()
        let characterDetailCoordinator = characterDetailCoordinatorFactory.createNew(characterId: id, navigationCoordinator: self)
        let viewController = characterDetailCoordinator.start()
        
        characterViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToLocationDetail(id: Int) {
        let locationDetailCoordinatorFactory: LocationDetailCoordinatorFactory = dependencies.resolve()
        let locationDetailCoordinator = locationDetailCoordinatorFactory.createNew(locationId: id, navigationCoordinator: self)
        let viewController = locationDetailCoordinator.start()
        
        characterViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToEpisodeDetail(id: Int) {
        let episodeDetailCoordinatorFactory: EpisodeDetailCoordinatorFactory = dependencies.resolve()
        let episodeDetailCoordinator = episodeDetailCoordinatorFactory.createNew(episodeId: id, navigationCoordinator: self)
        let viewController = episodeDetailCoordinator.start()
        
        characterViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}
