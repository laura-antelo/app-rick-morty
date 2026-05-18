//
//  RaMDependencies.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

protocol RickAndMortyDependencies: APIDependencies, EpisodeDependencies, CharacterDependencies, LocationDependencies { }

protocol APIDependencies {
    func resolve() -> APIClient
}

protocol EpisodeDependencies {
    func resolve() -> EpisodeRepository
    func resolve() -> GetEpisodesUseCase
    func resolve() -> GetEpisodeDetailUseCase
    func resolve() -> EpisodeListViewModel
    func resolve() -> EpisodeListViewController
    func resolve() -> EpisodeCoordinator
}

protocol CharacterDependencies {
    func resolve() -> CharacterRepository
    func resolve() -> GetCharactersUseCase
    func resolve() -> GetCharacterDetailUseCase
    func resolve() -> CharacterListViewModel
    func resolve() -> CharacterListViewController
    func resolve() -> CharacterCoordinator
}
protocol LocationDependencies {
    func resolve() -> LocationRepository
    func resolve() -> GetLocationsUseCase
    func resolve() -> GetLocationDetailUseCase
    func resolve() -> LocationListViewModel
    func resolve() -> LocationListViewController
    func resolve() -> LocationCoordinator
}
