//
//  EpisodeDetailCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import UIKit

protocol EpisodeDetailCoordinator {
    func start() -> UIViewController
}

protocol EpisodeDetailCoordinatorFactory {
    func createNew(episodeId: Int, navigationCoordinator: NavegationCoordinator) -> EpisodeDetailCoordinator
}

final class DefaultEpisodeDetailCoordinatorFactory: EpisodeDetailCoordinatorFactory {
    private let dependencies: EpisodeDependencies
    
    init(dependencies: EpisodeDependencies) {
        self.dependencies = dependencies
    }
    
    func createNew(episodeId: Int, navigationCoordinator: NavegationCoordinator) -> any EpisodeDetailCoordinator {
        return DefaultEpisodeDetailCoordinator(dependencies: dependencies, episodeId: episodeId, navigationCoordinator: navigationCoordinator)
    }
}


final class DefaultEpisodeDetailCoordinator: EpisodeDetailCoordinator {
    private let dependencies: EpisodeDependencies
    private let episodeId: Int
    private let navigationCoordinator: NavegationCoordinator
    
    init(dependencies: EpisodeDependencies, episodeId: Int, navigationCoordinator: NavegationCoordinator){
        self.dependencies = dependencies
        self.episodeId = episodeId
        self.navigationCoordinator = navigationCoordinator
    }
    
    func start() -> UIViewController {
        
        let viewModel = DefaultEpisodeDetailViewModel(episodeId: episodeId, dependencies: dependencies, navigationCoordinator: navigationCoordinator)
        
        return EpisodeDetailViewController(viewModel: viewModel)
    }
}
