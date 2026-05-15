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
    private weak var episodeViewContoller: UIViewController?
    
    init(dependencies: RickAndMortyDependencies) {
        self.dependencies = dependencies
    }
    
    func start() -> UIViewController {
        let viewController: EpisodeListViewController = dependencies.resolve()
        
        episodeViewContoller = viewController
        
        return viewController
    }
    
    func goToCharacterDetail(id: Int) {
        let viewModel = DefaultCharacterDetailViewModel(characterId: id, dependencies: dependencies, navigationCoordinator: self)
        
        let viewController = CharacterDetailViewController(viewModel: viewModel)
        
        episodeViewContoller?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToLocationDetail(id: Int) {
        let viewModel = DefaultLocationDetailViewModel(locationId: id, dependencies: dependencies, navigationCoordinator: self)
        
        let viewController = LocationDetailViewController(viewModel: viewModel)
        
        episodeViewContoller?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func goToEpisodeDetail(id: Int) {
        let viewModel = DefaultEpisodeDetailViewModel(episodeId: id, dependencies: dependencies, navigationCoordinator: self)
        
        let viewController = EpisodeDetailViewController(viewModel: viewModel)
        
        episodeViewContoller?.navigationController?.pushViewController(viewController, animated: true)
    }
}
