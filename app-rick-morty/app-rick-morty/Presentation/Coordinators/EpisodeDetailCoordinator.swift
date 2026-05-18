//
//  EpisodeDetailCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import UIKit

protocol EpisodeDetailCoordinator {
    func setEpisodeId(_ id: Int)
    func start() -> UIViewController
}

protocol EpisodeDetailCoordinatorFactory {
    func createNew(navegationCoordinator: NavegationCoordinator) -> EpisodeDetailCoordinator
}

final class DefaultEpisodeDetailCoordinatorFactory: EpisodeDetailCoordinatorFactory {
    private let dependencies: EpisodeDependencies
    
    init(dependencies: EpisodeDependencies) {
        self.dependencies = dependencies
    }
    
    func createNew(navegationCoordinator: any NavegationCoordinator) -> any EpisodeDetailCoordinator {
        return DefaultEpisodeDetailCoordinator(dependencies: dependencies, navegationCoordinator: navegationCoordinator)
    }
}


final class DefaultEpisodeDetailCoordinator: EpisodeDetailCoordinator {
    private let dependencies: EpisodeDependencies
    private weak var navegationCoordinator: NavegationCoordinator?
    private var episodeId: Int?
    
    init(dependencies: EpisodeDependencies, navegationCoordinator: NavegationCoordinator){
        self.dependencies = dependencies
        self.navegationCoordinator = navegationCoordinator
    }
    
    func setEpisodeId(_ id: Int) {
        episodeId = id
    }
    
    func start() -> UIViewController {
        guard let episodeId, let navegationCoordinator else { fatalError("Dependencies not set") }
        
        let viewModel = DefaultEpisodeDetailViewModel(episodeId: episodeId, dependencies: dependencies, navigationCoordinator: navegationCoordinator)
        
        return EpisodeDetailViewController(viewModel: viewModel)
    }
}
