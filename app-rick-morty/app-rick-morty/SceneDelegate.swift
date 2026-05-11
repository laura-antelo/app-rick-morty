//
//  SceneDelegate.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var episodeCoordinator = DefaultEpisodeCoordinator(dependencies: self)
    private lazy var characterCoordinator = DefaultCharacterCoordinator(dependencies: self)
    private lazy var locationCoordinator = DefaultLocationCoordinator(dependencies: self)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let mainWindow = UIWindow(windowScene: windowScene)
        window = mainWindow
        let mainCoordinator = DefaultMainCoordinator(window: mainWindow, dependencies: self)
        let initialViewController = mainCoordinator.start()
        mainWindow.rootViewController = initialViewController
        mainWindow.makeKeyAndVisible()
    }
}

extension SceneDelegate: RickAndMortyDependencies {
    func resolve() -> EpisodeListViewController {
        return EpisodeListViewController(dependencies: self)
    }
    
    func resolve() -> EpisodeCoordinator {
        return episodeCoordinator
    }
    
    func resolve() -> CharacterListViewController {
        return CharacterListViewController(dependencies: self)
    }
    
    func resolve() -> CharacterCoordinator {
        return characterCoordinator
    }
    
    func resolve() -> LocationListViewController {
        return LocationListViewController(dependencies: self)
    }
    
    func resolve() -> LocationCoordinator {
        return locationCoordinator
    }
}

