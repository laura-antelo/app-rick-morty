//
//  EpisodeCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

protocol EpisodeCoordinator {
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
}
