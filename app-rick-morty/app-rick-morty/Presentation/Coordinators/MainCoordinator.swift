//
//  MainCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

protocol MainCoordinator {
    func start() -> UIViewController
}

final class DefaultMainCoordinator: MainCoordinator {
    
    let window: UIWindow
    private let dependencies: RickAndMortyDependencies
    
    init(window: UIWindow, dependencies: RickAndMortyDependencies) {
        self.window = window
        self.dependencies = dependencies
    }
    
    func start() -> UIViewController {
        let episodeCoordinator: EpisodeCoordinator = dependencies.resolve()
        let characterCoordinator: CharacterCoordinator = dependencies.resolve()
        let locationCoordinator: LocationCoordinator = dependencies.resolve()
        
        let episodeViewController = episodeCoordinator.start()
        let characterViewController = characterCoordinator.start()
        let locationViewController = locationCoordinator.start()
        
        let episodeNavigationController = makeNavigationController(rootViewController: episodeViewController, title: "Episodios", image: UIImage(systemName: "tv"))
        let characterNavigationController = makeNavigationController(rootViewController: characterViewController, title: "Personajes", image: UIImage(systemName: "person.3"))
        let locationNavigationController = makeNavigationController(rootViewController: locationViewController, title: "Ubicaciones", image: UIImage(systemName: "globe.europe.africa"))
        
        return MainTabBarController(initialViewControllers: [episodeNavigationController, characterNavigationController, locationNavigationController])
    }
    
    private func makeNavigationController(rootViewController: UIViewController, title: String, image: UIImage?) -> UINavigationController {
        rootViewController.title = title
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: image)
        
        return navigationController
    }
}
