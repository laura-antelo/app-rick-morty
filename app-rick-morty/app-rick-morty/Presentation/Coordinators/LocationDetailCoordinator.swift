//
//  LocationDetailCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import UIKit

protocol LocationDetailCoordinator {
    func setLocationId(_ id: Int)
    func start() -> UIViewController
}

protocol LocationDetailCoordinatorFactory {
    func createNew(navegationCoordinator: NavegationCoordinator) -> LocationDetailCoordinator
}

final class DefaultLocationDetailCoordinatorFactory: LocationDetailCoordinatorFactory {
    private let dependencies: LocationDependencies
    
    init(dependencies: LocationDependencies) {
        self.dependencies = dependencies
    }
    
    func createNew(navegationCoordinator: any NavegationCoordinator) -> any LocationDetailCoordinator {
        return DefaultLocationDetailCoordinator(dependencies: dependencies, navegationCoordinator: navegationCoordinator)
    }
}


final class DefaultLocationDetailCoordinator: LocationDetailCoordinator {
    private let dependencies: LocationDependencies
    private weak var navegationCoordinator: NavegationCoordinator?
    private var locationId: Int?
    
    init(dependencies: LocationDependencies, navegationCoordinator: NavegationCoordinator){
        self.dependencies = dependencies
        self.navegationCoordinator = navegationCoordinator
    }
    
    func setLocationId(_ id: Int) {
        locationId = id
    }
    
    func start() -> UIViewController {
        guard let locationId, let navegationCoordinator else { fatalError("Dependencies not set") }
        
        let viewModel = DefaultLocationDetailViewModel(locationId: locationId, dependencies: dependencies, navigationCoordinator: navegationCoordinator)
        
        return LocationDetailViewController(viewModel: viewModel)
    }
}
