//
//  LocationDetailCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import UIKit

protocol LocationDetailCoordinator {
    func start() -> UIViewController
}

protocol LocationDetailCoordinatorFactory {
    func createNew(locationId: Int, navigationCoordinator: NavegationCoordinator) -> LocationDetailCoordinator
}

final class DefaultLocationDetailCoordinatorFactory: LocationDetailCoordinatorFactory {
    private let dependencies: RickAndMortyDependencies
    
    init(dependencies: RickAndMortyDependencies) {
        self.dependencies = dependencies
    }
    
    func createNew(locationId: Int, navigationCoordinator: NavegationCoordinator) -> any LocationDetailCoordinator {
        return DefaultLocationDetailCoordinator(dependencies: dependencies, locationId: locationId, navigationCoordinator: navigationCoordinator)
    }
}


final class DefaultLocationDetailCoordinator: LocationDetailCoordinator {
    private let dependencies: RickAndMortyDependencies
    private let locationId: Int
    private let navigationCoordinator: NavegationCoordinator
    
    init(dependencies: RickAndMortyDependencies, locationId: Int, navigationCoordinator: NavegationCoordinator){
        self.dependencies = dependencies
        self.locationId = locationId
        self.navigationCoordinator = navigationCoordinator
    }
    
    func start() -> UIViewController {
        
        let viewModel = DefaultLocationDetailViewModel(locationId: locationId, dependencies: dependencies, navigationCoordinator: navigationCoordinator)
        
        return LocationDetailViewController(viewModel: viewModel)
    }
}
