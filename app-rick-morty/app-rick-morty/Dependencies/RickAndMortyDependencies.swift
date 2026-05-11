//
//  RaMDependencies.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

protocol RickAndMortyDependencies {
    func resolve() -> EpisodeListViewController
    func resolve() -> EpisodeCoordinator
    func resolve() -> CharacterListViewController
    func resolve() -> CharacterCoordinator
    func resolve() -> LocationListViewController
    func resolve() -> LocationCoordinator
}
