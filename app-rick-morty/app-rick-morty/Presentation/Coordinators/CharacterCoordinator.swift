//
//  CharacterCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

protocol CharacterCoordinator {
    func start() -> UIViewController
}

final class DefaultCharacterCoordinator: CharacterCoordinator {
    private let dependencies: RickAndMortyDependencies
    private weak var characterViewContoller: UIViewController?
    
    init(dependencies: RickAndMortyDependencies) {
        self.dependencies = dependencies
    }
    
    func start() -> UIViewController {
        let viewController: CharacterListViewController = dependencies.resolve()
        
        characterViewContoller = viewController
        
        return viewController
    }
}
