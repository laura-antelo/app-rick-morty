//
//  SceneDelegate.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var apiClient: APIClient = URLSessionAPIClient()
    
    private lazy var diskCache: DiskCache = .shared
    
    private lazy var characterRepository: CharacterRepository = CacheCharacterDecorator(decoratedRepository: DefaultCharacterRepository(api: apiClient), cache: diskCache)
    private lazy var episodeRepository: EpisodeRepository = CacheEpisodeDecorator(decoratedRepository: DefaultEpisodeRepository(api: apiClient), cache: diskCache)
    private lazy var locationRepository: LocationRepository = CacheLocationDecorator(decoratedRepository: DefaultLocationRepository(api: apiClient), cache: diskCache)
    
    private lazy var favoriteRepository: FavoriteRepository = DefaultFavoriteRepository()
    
    private lazy var episodeViewModel: EpisodeListViewModel = DefaultEpisodeListViewModel(dependencies: self)
    private lazy var characterViewModel: CharacterListViewModel = DefaultCharacterListViewModel(dependencies: self)
    private lazy var locationViewModel: LocationListViewModel = DefaultLocationListViewModel(dependencies: self)
    
    private lazy var episodeCoordinator: EpisodeCoordinator = DefaultEpisodeCoordinator(dependencies: self)
    private lazy var characterCoordinator: CharacterCoordinator = DefaultCharacterCoordinator(dependencies: self)
    private lazy var locationCoordinator: LocationCoordinator = DefaultLocationCoordinator(dependencies: self)
    
    private lazy var episodeDetailCoordinatorFactory: EpisodeDetailCoordinatorFactory = DefaultEpisodeDetailCoordinatorFactory(dependencies: self)
    private lazy var characterDetailCoordinatorFactory: CharacterDetailCoordinatorFactory = DefaultCharacterDetailCoordinatorFactory(dependencies: self)
    private lazy var locationDetailCoordinatorFactory: LocationDetailCoordinatorFactory = DefaultLocationDetailCoordinatorFactory(dependencies: self)

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

extension SceneDelegate: RickAndMortyDependencies {}

extension SceneDelegate: APIDependencies {
    func resolve() -> APIClient {
        return apiClient
    }
}

extension SceneDelegate: FavoriteDependencies {
    
    func resolve() -> FavoriteRepository {
        return favoriteRepository
    }
    
    func resolve() -> GetFavoriteUseCase {
        return DefaultGetFavoriteUseCase(repository: favoriteRepository)
    }
    
    func resolve() -> IsFavoriteUseCase {
        return DefaultIsFavoriteUseCase(repository: favoriteRepository)
    }
    
    func resolve() -> ToggleFavoriteUseCase {
        return DefaultToggleFavoriteUseCase(repository: favoriteRepository)
    }
}
    
extension SceneDelegate: EpisodeDependencies {
    
    func resolve() -> any EpisodeRepository {
        return episodeRepository
    }
    
    func resolve() -> any GetEpisodesUseCase {
        return DefaultGetEpisodesUseCase(repository: resolve())
    }
    
    func resolve() -> any GetEpisodeDetailUseCase {
        return DefaultGetEpisodeDetailUseCase(repository: resolve())
    }
    
    func resolve() -> any EpisodeListViewModel {
        return episodeViewModel
    }
    
    func resolve() -> EpisodeListViewController {
        return EpisodeListViewController(viewModel: episodeViewModel)
    }
    
    func resolve() -> EpisodeCoordinator {
        return episodeCoordinator
    }
    
    func resolve() -> any EpisodeDetailCoordinatorFactory {
        return episodeDetailCoordinatorFactory
    }
}
    
extension SceneDelegate: CharacterDependencies {
    
    func resolve() -> any CharacterRepository {
        return characterRepository
    }
    
    func resolve() -> any GetCharactersUseCase {
        return DefaultGetCharactersUseCase(repository: resolve())
    }
    
    func resolve() -> any GetCharacterDetailUseCase {
        return DefaultGetCharacterDetailUseCase(repository: resolve())
    }
    
    func resolve() -> any CharacterListViewModel {
        return characterViewModel
    }
    
    func resolve() -> CharacterListViewController {
        return CharacterListViewController(viewModel: characterViewModel)
    }
    
    func resolve() -> CharacterCoordinator {
        return characterCoordinator
    }
    
    func resolve() -> any CharacterDetailCoordinatorFactory {
        return characterDetailCoordinatorFactory
    }
}
    
extension SceneDelegate: LocationDependencies {
    
    func resolve() -> any LocationRepository {
        return locationRepository
    }
    
    func resolve() -> any GetLocationsUseCase {
        return DefaultGetLocationsUseCase(repository: resolve())
    }
    
    func resolve() -> any GetLocationDetailUseCase {
        return DefaultGetLocationDetailUseCase(repository: resolve())
    }
    
    func resolve() -> any LocationListViewModel {
        return locationViewModel
    }
    
    func resolve() -> LocationListViewController {
        return LocationListViewController(viewModel: locationViewModel)
    }
    
    func resolve() -> LocationCoordinator {
        return locationCoordinator
    }
    
    func resolve() -> any LocationDetailCoordinatorFactory {
        return locationDetailCoordinatorFactory
    }
}

