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
    let favoriteRepositorySpy = FavoriteRepositorySpy()
    
    func resolve() -> FavoriteRepository {
        favoriteRepositorySpy
    }
    
    func resolve() -> GetFavoriteUseCase {
        DefaultGetFavoriteUseCase(repository: favoriteRepositorySpy)
    }
    
    func resolve() -> IsFavoriteUseCase {
        DefaultIsFavoriteUseCase(repository: favoriteRepositorySpy)
    }
    
    func resolve() -> ToggleFavoriteUseCase {
        DefaultToggleFavoriteUseCase(repository: favoriteRepositorySpy)
    }
    
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
    let favoriteRepositorySpy = FavoriteRepositorySpy()
    
    func resolve() -> FavoriteRepository {
        favoriteRepositorySpy
    }
    
    func resolve() -> GetFavoriteUseCase {
        DefaultGetFavoriteUseCase(repository: favoriteRepositorySpy)
    }
    
    func resolve() -> IsFavoriteUseCase {
        DefaultIsFavoriteUseCase(repository: favoriteRepositorySpy)
    }
    
    func resolve() -> ToggleFavoriteUseCase {
        DefaultToggleFavoriteUseCase(repository: favoriteRepositorySpy)
    }
    
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
    let favoriteRepositorySpy = FavoriteRepositorySpy()
    
    func resolve() -> FavoriteRepository {
        favoriteRepositorySpy
    }
    
    func resolve() -> GetFavoriteUseCase {
        DefaultGetFavoriteUseCase(repository: favoriteRepositorySpy)
    }
    
    func resolve() -> IsFavoriteUseCase {
        DefaultIsFavoriteUseCase(repository: favoriteRepositorySpy)
    }
    
    func resolve() -> ToggleFavoriteUseCase {
        DefaultToggleFavoriteUseCase(repository: favoriteRepositorySpy)
    }
    
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

final class RickAndMortyDependenciesMock: RickAndMortyDependencies {
    let apiDependenciesMock = APIDependenciesMock()
    let characterDependenciesMock = CharacterDependenciesMock()
    let episodeDependenciesMock = EpisodeDependenciesMock()
    let locationDependenciesMock = LocationDependenciesMock()
    let favoriteRepositorySpy = FavoriteRepositorySpy()
    
    func resolve() -> any APIClient {
        apiDependenciesMock.resolve()
    }
    
    func resolve() -> any EpisodeRepository {
        episodeDependenciesMock.resolve()
    }
    
    func resolve() -> any GetEpisodesUseCase {
        episodeDependenciesMock.resolve()
    }
    
    func resolve() -> any GetEpisodeDetailUseCase {
        episodeDependenciesMock.resolve()
    }
    
    func resolve() -> any EpisodeListViewModel {
        episodeDependenciesMock.resolve()
    }
    
    func resolve() -> EpisodeListViewController {
        episodeDependenciesMock.resolve()
    }
    
    func resolve() -> any EpisodeCoordinator {
        episodeDependenciesMock.resolve()
    }
    
    func resolve() -> any EpisodeDetailCoordinatorFactory {
        episodeDependenciesMock.resolve()
    }
    
    func resolve() -> any CharacterRepository {
        characterDependenciesMock.resolve()
    }
    
    func resolve() -> any GetCharactersUseCase {
        characterDependenciesMock.resolve()
    }
    
    func resolve() -> any GetCharacterDetailUseCase {
        characterDependenciesMock.resolve()
    }
    
    func resolve() -> any CharacterListViewModel {
        characterDependenciesMock.resolve()
    }
    
    func resolve() -> CharacterListViewController {
        characterDependenciesMock.resolve()
    }
    
    func resolve() -> any CharacterCoordinator {
        characterDependenciesMock.resolve()
    }
    
    func resolve() -> any CharacterDetailCoordinatorFactory {
        characterDependenciesMock.resolve()
    }
    
    func resolve() -> any LocationRepository {
        locationDependenciesMock.resolve()
    }
    
    func resolve() -> any GetLocationsUseCase {
        locationDependenciesMock.resolve()
    }
    
    func resolve() -> any GetLocationDetailUseCase {
        locationDependenciesMock.resolve()
    }
    
    func resolve() -> any LocationListViewModel {
        locationDependenciesMock.resolve()
    }
    
    func resolve() -> LocationListViewController {
        locationDependenciesMock.resolve()
    }
    
    func resolve() -> any LocationCoordinator {
        locationDependenciesMock.resolve()
    }
    
    func resolve() -> any LocationDetailCoordinatorFactory {
        locationDependenciesMock.resolve()
    }
    
    func resolve() -> any FavoriteRepository {
        favoriteRepositorySpy
    }
    
    func resolve() -> any GetFavoriteUseCase {
        DefaultGetFavoriteUseCase(repository: favoriteRepositorySpy)
    }
    
    func resolve() -> any IsFavoriteUseCase {
        DefaultIsFavoriteUseCase(repository: favoriteRepositorySpy)
    }
    
    func resolve() -> any ToggleFavoriteUseCase {
        DefaultToggleFavoriteUseCase(repository: favoriteRepositorySpy)
    }
}
