//
//  EpisodeCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

protocol EpisodeCoordinator: NavegationCoordinator {
    func start() -> UIViewController
}

final class DefaultEpisodeCoordinator: EpisodeCoordinator {
    private let dependencies: RickAndMortyDependencies
    private weak var episodeViewController: UIViewController?
    
    init(dependencies: RickAndMortyDependencies) {
        self.dependencies = dependencies
    }
    
    func start() -> UIViewController {
        let viewController: EpisodeListViewController = dependencies.resolve()
        
        episodeViewController = viewController
        
        return viewController
    }
    
    func goToCharacterDetail(id: Int) {
        let characterDetailCoordinatorFactory: CharacterDetailCoordinatorFactory = dependencies.resolve()
        let characterDetailCoordinator = characterDetailCoordinatorFactory.createNew(characterId: id, navigationCoordinator: self)
        let viewController = characterDetailCoordinator.start()
        
        episodeViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToLocationDetail(id: Int) {
        let locationDetailCoordinatorFactory: LocationDetailCoordinatorFactory = dependencies.resolve()
        let locationDetailCoordinator = locationDetailCoordinatorFactory.createNew(locationId: id, navigationCoordinator: self)
        let viewController = locationDetailCoordinator.start()
        
        episodeViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToEpisodeDetail(id: Int) {
        let episodeDetailCoordinatorFactory: EpisodeDetailCoordinatorFactory = dependencies.resolve()
        let episodeDetailCoordinator = episodeDetailCoordinatorFactory.createNew(episodeId: id, navigationCoordinator: self)
        let viewController = episodeDetailCoordinator.start()
        
        episodeViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}
