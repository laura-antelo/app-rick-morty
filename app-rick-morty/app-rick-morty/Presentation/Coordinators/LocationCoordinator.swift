//
//  LocationCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

protocol LocationCoordinator {
    func start() -> UIViewController
}

final class DefaultLocationCoordinator: LocationCoordinator {
    private let dependencies: RickAndMortyDependencies
    private weak var locationViewContoller: UIViewController?
    
    init(dependencies: RickAndMortyDependencies) {
        self.dependencies = dependencies
    }
    
    func start() -> UIViewController {
        let viewController: LocationListViewController = dependencies.resolve()
        
        locationViewContoller = viewController
        
        return viewController
    }
}
