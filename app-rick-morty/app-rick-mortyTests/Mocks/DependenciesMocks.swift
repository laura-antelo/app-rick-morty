//
//  DependenciesMocks.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 21/5/26.
//

import UIKit
@testable import app_rick_morty

final class APIDependenciesMock: APIDependencies {
    let apiClientSpy = APIClientSpy()
    
    func resolve() -> APIClient {
        apiClientSpy
    }
}

final class CharacterDependenciesMock: CharacterDependencies {
    
    let characterRepositorySpy = CharacterRepositorySpy()
    let getCharacterUseCaseSpy = GetCharactersUseCaseSpy()
    let getCharacterDetailUseCaseSpy = GetCharacterDetailUseCaseSpy()
    let characterCoordinatorSpy = CoordinatorSpy()
    let characterDetailCoordinatorFactorySpy = CharacterDetailCoordinatorFactorySpy()
    
    func resolve() -> CharacterRepository {
        characterRepositorySpy
    }
    
    func resolve() -> GetCharactersUseCase {
        getCharacterUseCaseSpy
    }
    
    func resolve() -> GetCharacterDetailUseCase {
        getCharacterDetailUseCaseSpy
    }
    
    func resolve() -> CharacterListViewModel {
        DefaultCharacterListViewModel(dependencies: self)
    }
    
    func resolve() -> CharacterListViewController {
        return CharacterListViewController(viewModel: resolve())
    }
    
    func resolve() -> CharacterCoordinator {
        characterCoordinatorSpy
    }
    
    func resolve() -> CharacterDetailCoordinatorFactory {
        characterDetailCoordinatorFactorySpy
    }
}

final class LocationDependenciesMock: LocationDependencies {
    
    let locationRepositorySpy = LocationRepositorySpy()
    let getLocationUseCaseSpy = GetLocationsUseCaseSpy()
    let getLocationDetailUseCaseSpy = GetLocationDetailUseCaseSpy()
    let locationCoordinatorSpy = CoordinatorSpy()
    let locationDetailCoordinatorFactorySpy = LocationDetailCoordinatorFactorySpy()
    
    func resolve() -> LocationRepository {
        locationRepositorySpy
    }
    
    func resolve() -> GetLocationsUseCase {
        getLocationUseCaseSpy
    }
    
    func resolve() -> GetLocationDetailUseCase {
        getLocationDetailUseCaseSpy
    }
    
    func resolve() -> LocationListViewModel {
        DefaultLocationListViewModel(dependencies: self)
    }
    
    func resolve() -> LocationListViewController {
        return LocationListViewController(viewModel: resolve())
    }
    
    func resolve() -> LocationCoordinator {
        locationCoordinatorSpy
    }
    
    func resolve() -> LocationDetailCoordinatorFactory {
        locationDetailCoordinatorFactorySpy
    }
}

final class EpisodeDependenciesMock: EpisodeDependencies {
    
    let episodeRepositorySpy = EpisodeRepositorySpy()
    let getEpisodesUseCaseSpy = GetEpisodesUseCaseSpy()
    let getEpisodeDetailUseCaseSpy = GetEpisodeDetailUseCaseSpy()
    let episodeCoordinatorSpy = CoordinatorSpy()
    let episodeDetailCoordinatorFactorySpy = EpisodeDetailCoordinatorFactorySpy()
    
    func resolve() -> EpisodeRepository {
        episodeRepositorySpy
    }
    
    func resolve() -> GetEpisodesUseCase {
        getEpisodesUseCaseSpy
    }
    
    func resolve() -> GetEpisodeDetailUseCase {
        getEpisodeDetailUseCaseSpy
    }
    
    func resolve() -> EpisodeListViewModel {
        DefaultEpisodeListViewModel(dependencies: self)
    }
    
    func resolve() -> EpisodeListViewController {
        return EpisodeListViewController(viewModel: resolve())
    }
    
    func resolve() -> EpisodeCoordinator {
        episodeCoordinatorSpy
    }
    
    func resolve() -> EpisodeDetailCoordinatorFactory {
        episodeDetailCoordinatorFactorySpy
    }
}
